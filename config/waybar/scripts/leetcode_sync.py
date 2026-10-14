#!/usr/bin/env python3
import json
import os
import re
import shutil
import signal
import sqlite3
import subprocess
import sys
import tempfile
import time
import urllib.request

CONFIG_FILE = os.path.expanduser("~/.config/waybar/leetcode.json")
SOLVED_FILE = os.path.expanduser("~/.config/waybar/leetcode_solved.json")
STATE_FILE = os.path.expanduser("~/.config/waybar/dsa_state.json")
DATA_FILE = os.path.expanduser("~/.config/waybar/scripts/dsa_data.json")

DEFAULT_USERNAME = "the__ronakgupta"

def get_config():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {"username": DEFAULT_USERNAME, "auto_sync": True}

def get_firefox_cookies():
    ff_dir = os.path.expanduser("~/.mozilla/firefox")
    if not os.path.exists(ff_dir):
        return {}
    for profile in os.listdir(ff_dir):
        if "default" in profile:
            cookie_path = os.path.join(ff_dir, profile, "cookies.sqlite")
            if os.path.exists(cookie_path):
                try:
                    with tempfile.NamedTemporaryFile() as tmp:
                        shutil.copyfile(cookie_path, tmp.name)
                        conn = sqlite3.connect(tmp.name)
                        cursor = conn.cursor()
                        cursor.execute("SELECT name, value FROM moz_cookies WHERE host LIKE '%leetcode.com%'")
                        cookies = dict(cursor.fetchall())
                        conn.close()
                        if "LEETCODE_SESSION" in cookies:
                            return cookies
                except Exception:
                    pass
    return {}

def fetch_authenticated_problems(cookies):
    session = cookies.get("LEETCODE_SESSION")
    csrf = cookies.get("csrftoken", "")
    if not session:
        return None
    url = "https://leetcode.com/api/problems/all/"
    req = urllib.request.Request(
        url,
        headers={
            "Cookie": f"LEETCODE_SESSION={session}; csrftoken={csrf}",
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64)",
            "x-csrftoken": csrf,
            "Referer": "https://leetcode.com/"
        }
    )
    try:
        with urllib.request.urlopen(req, timeout=12) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            ac_map = {}
            for p in data.get("stat_status_pairs", []):
                if p.get("status") == "ac":
                    stat = p["stat"]
                    fid = str(stat["frontend_question_id"])
                    ac_map[fid] = {
                        "id": fid,
                        "title": stat["question__title"],
                        "slug": stat["question__title_slug"]
                    }
            username = data.get("user_name") or DEFAULT_USERNAME
            return ac_map, username
    except Exception as e:
        print(f"Authenticated API request failed: {e}", file=sys.stderr)
        return None

def fetch_public_graphql(username):
    url = "https://leetcode.com/graphql"
    query = """
    query getUserProfile($username: String!) {
      matchedUser(username: $username) {
        username
        submitStatsGlobal {
          acSubmissionNum {
            difficulty
            count
          }
        }
      }
      recentAcSubmissionList(username: $username, limit: 100) {
        id
        title
        titleSlug
      }
    }
    """
    req = urllib.request.Request(
        url,
        data=json.dumps({"query": query, "variables": {"username": username}}).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64)"
        }
    )
    try:
        with urllib.request.urlopen(req, timeout=12) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            subs = data.get("data", {}).get("recentAcSubmissionList", [])
            ac_map = {}
            for s in subs:
                # In recentAcSubmissionList, titleSlug is available
                ac_map[s["titleSlug"]] = {
                    "slug": s["titleSlug"],
                    "title": s["title"]
                }
            return ac_map, username
    except Exception as e:
        print(f"Public GraphQL request failed: {e}", file=sys.stderr)
        return None

def notify_waybar():
    try:
        sig = signal.SIGRTMIN + 10
        pids = subprocess.check_output(["pidof", "waybar"]).decode().split()
        for p in pids:
            os.kill(int(p), sig)
    except Exception:
        pass

def sync():
    config = get_config()
    username = config.get("username", DEFAULT_USERNAME)

    ac_problems = None
    fetched_user = username

    # 1. Try authenticated API via Firefox cookies
    cookies = get_firefox_cookies()
    if cookies:
        res = fetch_authenticated_problems(cookies)
        if res:
            ac_problems, fetched_user = res

    # 2. Fallback to public GraphQL if needed
    if ac_problems is None:
        res = fetch_public_graphql(username)
        if res:
            ac_problems, fetched_user = res
        elif username != DEFAULT_USERNAME:
            res = fetch_public_graphql(DEFAULT_USERNAME)
            if res:
                ac_problems, fetched_user = res

    if ac_problems is None:
        print("Failed to sync LeetCode data (network or session issue).", file=sys.stderr)
        return False

    # Load curriculum data to extract problem mappings
    curriculum = []
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, "r") as f:
            curriculum = json.load(f)

    # Build mapping of chapter -> problem IDs
    chapter_problems = {}
    all_curriculum_ids = set()
    for part in curriculum:
        for ch in part.get("chapters", []):
            ch_ids = []
            for it in ch.get("items", []):
                m = re.search(r'LC\s*(\d+)', it)
                if m:
                    cid = m.group(1)
                    ch_ids.append(cid)
                    all_curriculum_ids.add(cid)
            chapter_problems[ch["num"]] = ch_ids

    # Identify solved problem IDs
    solved_ids = set()
    solved_slugs = set()
    for k, v in ac_problems.items():
        if "id" in v:
            solved_ids.add(v["id"])
        if "slug" in v:
            solved_slugs.add(v["slug"])

    # If only slugs were found (from GraphQL fallback), try to map them to IDs
    # (our authenticated endpoint provides exact frontend IDs)
    solved_in_curriculum = sorted(list(solved_ids.intersection(all_curriculum_ids)), key=lambda x: int(x))

    # Save solved cache
    solved_cache = {
        "username": fetched_user,
        "total_solved": len(ac_problems),
        "curriculum_solved_count": len(solved_in_curriculum),
        "solved_ids": sorted(list(solved_ids), key=lambda x: int(x) if x.isdigit() else 0),
        "solved_in_curriculum": solved_in_curriculum,
        "last_sync": int(time.time()),
        "last_sync_human": time.strftime("%Y-%m-%d %H:%M:%S")
    }
    with open(SOLVED_FILE, "w") as f:
        json.dump(solved_cache, f, indent=2)

    # Update dsa_state.json
    state = {"completed_chapters": [], "auto_completed": []}
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                state = json.load(f)
        except Exception:
            pass

    completed_set = set(state.get("completed_chapters", []))
    auto_completed = []

    # Check each chapter: if all its practice problems are solved, auto-tick the chapter
    for ch_num, prob_ids in chapter_problems.items():
        if prob_ids:
            all_solved = all(pid in solved_ids for pid in prob_ids)
            if all_solved:
                completed_set.add(ch_num)
                auto_completed.append(ch_num)

    state["completed_chapters"] = sorted(list(completed_set))
    state["auto_completed"] = auto_completed
    state["solved_questions"] = solved_in_curriculum
    state["leetcode_user"] = fetched_user
    state["last_sync"] = int(time.time())

    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)

    notify_waybar()
    print(f"Synced {fetched_user}: {len(ac_problems)} total solved, {len(solved_in_curriculum)} in curriculum, {len(auto_completed)} chapters fully completed.")
    return True

if __name__ == "__main__":
    sync()
