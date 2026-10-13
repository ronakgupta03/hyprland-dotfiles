#!/usr/bin/env python3
import json
import os
import sys
import time
import urllib.request

CONFIG_FILE = os.path.expanduser("~/.config/sway/codeforces.json")
CACHE_FILE = "/tmp/codeforces_waybar_activity_cache.json"
CACHE_TTL = 600  # 10 minutes

def get_handle():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r") as f:
                data = json.load(f)
                return data.get("handle", "").strip()
        except Exception:
            pass
    return "the.ronak.gupta"

def rank_to_color(rank):
    if not rank:
        return "#7dcfff", "unrated"
    r = rank.lower()
    if "legendary" in r or "grandmaster" in r:
        return "#ff3333", "grandmaster"
    elif "master" in r:
        return "#ffbb55", "master"
    elif "candidate" in r:
        return "#cc66ff", "candidate-master"
    elif "expert" in r:
        return "#6699ff", "expert"
    elif "specialist" in r:
        return "#33ddbb", "specialist"
    elif "pupil" in r:
        return "#55ee55", "pupil"
    elif "newbie" in r:
        return "#aaaaaa", "newbie"
    return "#7dcfff", "unrated"

def fetch_activity(handle):
    # Check cache
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                cached = json.load(f)
                if cached.get("handle") == handle and time.time() - cached.get("time", 0) < CACHE_TTL:
                    return cached.get("data")
        except Exception:
            pass

    headers = {"User-Agent": "Mozilla/5.0 (Waybar-Codeforces-Activity)"}
    data = {}

    try:
        # 1. User Info
        req1 = urllib.request.Request(f"https://codeforces.com/api/user.info?handles={handle}", headers=headers)
        with urllib.request.urlopen(req1, timeout=5) as r:
            res1 = json.loads(r.read().decode("utf-8"))
            if res1.get("status") == "OK" and res1.get("result"):
                data["user"] = res1["result"][0]
    except Exception:
        pass

    if "user" not in data:
        # Network error or invalid handle
        if os.path.exists(CACHE_FILE):
            try:
                with open(CACHE_FILE, "r") as f:
                    return json.load(f).get("data")
            except Exception:
                pass
        return None

    try:
        # 2. Rating & Contest history
        req2 = urllib.request.Request(f"https://codeforces.com/api/user.rating?handle={handle}", headers=headers)
        with urllib.request.urlopen(req2, timeout=5) as r:
            res2 = json.loads(r.read().decode("utf-8"))
            if res2.get("status") == "OK":
                data["contests"] = res2.get("result", [])
    except Exception:
        data["contests"] = []

    try:
        # 3. Recent Submissions
        req3 = urllib.request.Request(f"https://codeforces.com/api/user.status?handle={handle}&from=1&count=50", headers=headers)
        with urllib.request.urlopen(req3, timeout=5) as r:
            res3 = json.loads(r.read().decode("utf-8"))
            if res3.get("status") == "OK":
                data["submissions"] = res3.get("result", [])
    except Exception:
        data["submissions"] = []

    # Write cache
    try:
        with open(CACHE_FILE, "w") as f:
            json.dump({"handle": handle, "time": time.time(), "data": data}, f)
    except Exception:
        pass

    return data

def build_pango_tooltip(handle, data):
    user = data.get("user", {})
    contests = data.get("contests", [])
    subs = data.get("submissions", [])

    rating = user.get("rating", "Unrated")
    max_rating = user.get("maxRating", rating)
    rank = user.get("rank", "unrated").title()
    max_rank = user.get("maxRank", rank).title()
    org = user.get("organization", "N/A")
    contrib = user.get("contribution", 0)
    contrib_str = f"+{contrib}" if contrib > 0 else f"{contrib}"

    rank_color, _ = rank_to_color(user.get("rank", ""))
    max_rank_color, _ = rank_to_color(user.get("maxRank", ""))

    total_contests = len(contests)
    if contests:
        last = contests[-1]
        last_name = last.get("contestName", "N/A")
        if len(last_name) > 36:
            last_name = last_name[:34] + "…"
        last_rank = last.get("rank", "N/A")
        delta = last.get("newRating", 0) - last.get("oldRating", 0)
        delta_str = f"+{delta}" if delta > 0 else f"{delta}"
        delta_color = "#9ece6a" if delta >= 0 else "#f7768e"
    else:
        last_name = "None"
        last_rank = "-"
        delta_str = "0"
        delta_color = "#c0caf5"

    solved_set = set()
    verdicts = {}
    for s in subs:
        v = s.get("verdict", "OTHER")
        verdicts[v] = verdicts.get(v, 0) + 1
        if v == "OK":
            p = s.get("problem", {})
            solved_set.add(f"{p.get('contestId')}{p.get('index')}")

    ok_count = verdicts.get("OK", 0)
    wa_count = verdicts.get("WRONG_ANSWER", 0)

    lines = [
        f'<span size="12000" weight="bold" color="#7dcfff">󰲋 CODEFORCES PROFILE</span>  <span size="11000" weight="bold" color="{rank_color}">{handle}</span>',
        f'<span color="#565f89">────────────────────────────────────────────</span>',
        f'  <b>Current Rank:</b>   <span color="{rank_color}" weight="bold">{rank}</span>  (Rating: <span color="{rank_color}" weight="bold">{rating}</span>)',
        f'  <b>Peak Record:</b>    <span color="{max_rank_color}" weight="bold">{max_rank}</span>  (Max: <span color="{max_rank_color}" weight="bold">{max_rating}</span>)',
        f'  <b>Contests:</b>       <span color="#bb9af7" weight="bold">{total_contests}</span> official rounds attended',
        f'<span color="#565f89">────────────────────────────────────────────</span>',
        f'  <b>Last Contest:</b>   <span color="#e0af68">{last_name}</span>',
        f'  <b>Performance:</b>    Rank <span color="#7dcfff" weight="bold">#{last_rank}</span>   Rating <span color="{delta_color}" weight="bold">{delta_str}</span>',
        f'  <b>Recent Solved:</b>  <span color="#9ece6a" weight="bold">{len(solved_set)}</span> unique problems (OK: {ok_count}, WA: {wa_count})',
        f'  <b>Affiliation:</b>    <span color="#c0caf5">{org}</span> (Contrib: {contrib_str})',
        f'<span color="#565f89">────────────────────────────────────────────</span>',
        f'<span size="9000" color="#7aa2f7">󰌌 Left-click: Open Profile</span>   <span size="9000" color="#565f89">·   󰍜 Right-click: Edit Handle</span>'
    ]
    return "\n".join(lines)

def main():
    handle = get_handle()
    if not handle:
        output = {
            "text": "󰲋 CF: Set Handle",
            "tooltip": "Codeforces tracker\nClick to set handle in ~/.config/sway/codeforces.json",
            "class": "unset"
        }
        print(json.dumps(output))
        return

    data = fetch_activity(handle)
    if not data or "user" not in data:
        output = {
            "text": f"󰲋 {handle}",
            "tooltip": f"Codeforces: {handle}\nCould not load rating (check handle or network)",
            "class": "error"
        }
        print(json.dumps(output))
        return

    user = data["user"]
    rating = user.get("rating", "Unrated")
    rank = user.get("rank", "unrated").title()
    _, rank_cls = rank_to_color(user.get("rank", ""))

    tooltip = build_pango_tooltip(handle, data)

    output = {
        "text": f"󰲋 {handle}: {rating} ({rank})",
        "tooltip": tooltip,
        "class": rank_cls
    }
    print(json.dumps(output))

if __name__ == "__main__":
    main()
