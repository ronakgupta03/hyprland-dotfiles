#!/usr/bin/env python3
import json
import os
import re
import sys

STATE_FILE = os.path.expanduser("~/.config/waybar/dsa_state.json")
SOLVED_FILE = os.path.expanduser("~/.config/waybar/leetcode_solved.json")
DATA_FILE = os.path.expanduser("~/.config/waybar/scripts/dsa_data.json")

def load_data():
    if not os.path.exists(DATA_FILE):
        return []
    with open(DATA_FILE, "r") as f:
        return json.load(f)

def load_state():
    if not os.path.exists(STATE_FILE):
        return {"completed_chapters": []}
    try:
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return {"completed_chapters": []}

def load_leetcode():
    if not os.path.exists(SOLVED_FILE):
        return {}
    try:
        with open(SOLVED_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return {}

def make_bar(pct, width=14):
    filled = int(round((pct / 100.0) * width))
    filled = max(0, min(width, filled))
    return "█" * filled + "░" * (width - filled)

def main():
    data = load_data()
    state = load_state()
    lc = load_leetcode()

    done_ch_set = set(state.get("completed_chapters", []))
    solved_lc_ids = set(lc.get("solved_ids", []))
    lc_user = lc.get("username", "the__ronakgupta")
    total_lc_solved = lc.get("total_solved", 0)

    total_ch = sum(len(p["chapters"]) for p in data)
    total_q = sum(p["total_questions"] for p in data)

    done_ch = len(done_ch_set)
    done_q = 0

    part_stats = []
    for p in data:
        p_ch_done = 0
        p_q_done = 0
        p_total_ch = len(p["chapters"])
        p_total_q = p["total_questions"]

        for ch in p["chapters"]:
            is_ch_done = ch["num"] in done_ch_set
            if is_ch_done:
                p_ch_done += 1
                p_q_done += ch["q_count"]
            else:
                # count individual solved questions from LeetCode
                ch_solved = 0
                for it in ch.get("items", []):
                    m = re.search(r'LC\s*(\d+)', it)
                    if m and m.group(1) in solved_lc_ids:
                        ch_solved += 1
                p_q_done += ch_solved

        done_q += p_q_done

        part_stats.append({
            "name": f"{p['part_eyebrow']}: {p['part_name']}",
            "ch_done": p_ch_done,
            "ch_total": p_total_ch,
            "q_done": p_q_done,
            "q_total": p_total_q,
        })

    ch_pct = (done_ch / total_ch * 100) if total_ch > 0 else 0
    q_pct = (done_q / total_q * 100) if total_q > 0 else 0

    bar = make_bar(q_pct, 14)

    # Tooltip using Pango markup
    lines = [
        '<span size="12000" weight="bold" color="#7dcfff">󰉻 DSA CURRICULUM TRACKER</span>',
        '<span color="#565f89">────────────────────────────────────────────</span>',
        f'<b>LeetCode Account:</b> <span color="#73daca" weight="bold">{lc_user}</span> ({total_lc_solved} solved)',
        f'<b>Overall Progress:</b> <span color="#73daca" weight="bold">[{bar}] {q_pct:.1f}%</span>',
        f'<b>Chapters Done:</b>    <span color="#bb9af7" weight="bold">{done_ch}</span> / {total_ch} ({ch_pct:.1f}%)',
        f'<b>Questions Done:</b>   <span color="#7dcfff" weight="bold">{done_q}</span> / {total_q} ({q_pct:.1f}%)',
        '<span color="#565f89">────────────────────────────────────────────</span>',
        '<b>Breakdown by Part:</b>'
    ]

    for p in part_stats:
        status_color = "#73daca" if (p["ch_done"] == p["ch_total"] and p["ch_total"] > 0) else ("#c0caf5" if p["q_done"] > 0 else "#565f89")
        p_name = p["name"][:24].ljust(24)
        ch_str = f"{p['ch_done']}/{p['ch_total']} ch".rjust(9)
        q_str = f"{p['q_done']}/{p['q_total']} Qs".rjust(10)
        lines.append(f'  <span color="{status_color}">{p_name}</span>  <span color="#a9b1d6">{ch_str}</span> <span color="#7dcfff">{q_str}</span>')

    lines.append('<span color="#565f89">────────────────────────────────────────────</span>')
    lines.append('<span size="9000" color="#7dcfff">󰍜 Left Click: Toggle checklist popup</span>')

    tooltip = "\n".join(lines)

    text = f"󰉻 DSA: {done_ch}/{total_ch} · {done_q}/{total_q} Qs" if (done_ch > 0 or done_q > 0) else f"󰉻 DSA: 0/{total_ch}"

    output = {
        "text": text,
        "tooltip": tooltip,
        "class": "complete" if done_ch == total_ch and total_ch > 0 else ("active" if (done_ch > 0 or done_q > 0) else "idle"),
        "percentage": round(q_pct, 1)
    }

    print(json.dumps(output))

if __name__ == "__main__":
    main()
