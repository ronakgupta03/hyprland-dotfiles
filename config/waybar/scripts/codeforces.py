#!/usr/bin/env python3
import json
import os
import sys
import time
import urllib.request

CONFIG_FILE = os.path.expanduser("~/.config/sway/codeforces.json")
CACHE_FILE = "/tmp/codeforces_waybar_cache.json"
CACHE_TTL = 600  # 10 minutes

def get_handle():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r") as f:
                data = json.load(f)
                return data.get("handle", "").strip()
        except Exception:
            pass
    return ""

def rank_to_class(rank):
    if not rank:
        return "unrated"
    r = rank.lower()
    if "legendary" in r or "grandmaster" in r:
        return "grandmaster"
    elif "master" in r:
        return "master"
    elif "candidate" in r:
        return "candidate-master"
    elif "expert" in r:
        return "expert"
    elif "specialist" in r:
        return "specialist"
    elif "pupil" in r:
        return "pupil"
    elif "newbie" in r:
        return "newbie"
    return "unrated"

def fetch_cf_user(handle):
    # Check cache
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                cached = json.load(f)
                if cached.get("handle") == handle and time.time() - cached.get("time", 0) < CACHE_TTL:
                    return cached.get("data")
        except Exception:
            pass

    url = f"https://codeforces.com/api/user.info?handles={handle}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (Waybar-Codeforces-Module)"})
    try:
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            if data.get("status") == "OK" and data.get("result"):
                user_info = data["result"][0]
                # Cache it
                with open(CACHE_FILE, "w") as f:
                    json.dump({"handle": handle, "time": time.time(), "data": user_info}, f)
                return user_info
    except Exception:
        pass

    # If network failed, return existing cache if available
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                return json.load(f).get("data")
        except Exception:
            pass
    return None

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

    user = fetch_cf_user(handle)
    if not user:
        output = {
            "text": f"󰲋 {handle}",
            "tooltip": f"Codeforces: {handle}\nCould not load rating (check handle or network)",
            "class": "error"
        }
        print(json.dumps(output))
        return

    rating = user.get("rating", "Unrated")
    max_rating = user.get("maxRating", rating)
    rank = user.get("rank", "unrated").title()
    max_rank = user.get("maxRank", rank).title()
    org = user.get("organization", "N/A")

    rank_cls = rank_to_class(user.get("rank", ""))
    
    output = {
        "text": f"󰲋 {handle}: {rating} ({rank})",
        "tooltip": f"Codeforces: {handle}\nRating: {rating} (Max: {max_rating})\nRank: {rank} (Max: {max_rank})\nOrg: {org}\n\nLeft-click: Open Profile\nRight-click: Edit Handle",
        "class": rank_cls
    }
    print(json.dumps(output))

if __name__ == "__main__":
    main()
