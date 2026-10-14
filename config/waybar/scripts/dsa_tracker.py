#!/usr/bin/env python3
import json
import os
import re
import signal
import socket
import subprocess
import sys
import threading
import time
import webbrowser

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, Gdk, GLib, GtkLayerShell

STATE_FILE = os.path.expanduser("~/.config/waybar/dsa_state.json")
DATA_FILE = os.path.expanduser("~/.config/waybar/scripts/dsa_data.json")
SOLVED_FILE = os.path.expanduser("~/.config/waybar/leetcode_solved.json")
SLUGS_FILE = os.path.expanduser("~/.config/waybar/scripts/leetcode_slugs.json")
CONFIG_FILE = os.path.expanduser("~/.config/waybar/leetcode.json")
SYNC_SCRIPT = os.path.expanduser("~/.config/waybar/scripts/leetcode_sync.py")
SOCK_PATH = "/tmp/dsa_tracker_waybar.sock"

CSS = b"""
* {
    font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", "Inter Variable", sans-serif;
}

window.dsa-window {
    background-color: #1a1b26;
    border: 1px solid #3b4261;
    border-radius: 18px;
    box-shadow: 0 12px 36px rgba(0, 0, 0, 0.65);
}

.main-container {
    padding: 16px 18px;
}

.header-title {
    font-size: 16px;
    font-weight: bold;
    color: #7dcfff;
}

.header-stats {
    font-size: 12px;
    color: #a9b1d6;
}

progressbar trough {
    background-color: #24283b;
    border: 1px solid #3b4261;
    border-radius: 6px;
    min-height: 8px;
}

progressbar progress {
    background-color: #7dcfff;
    border-radius: 6px;
    min-height: 8px;
}

searchentry {
    background-color: #24283b;
    border: 1px solid #3b4261;
    border-radius: 10px;
    color: #c0caf5;
    padding: 6px 10px;
}

searchentry:focus {
    border-color: #7dcfff;
}

.action-btn {
    background-color: #24283b;
    border: 1px solid #3b4261;
    border-radius: 8px;
    color: #a9b1d6;
    padding: 4px 10px;
    font-size: 12px;
}

.action-btn:hover {
    background-color: #2f334d;
    color: #7dcfff;
    border-color: #7dcfff;
}

.sync-btn {
    background-color: #1f3340;
    border: 1px solid #7dcfff;
    border-radius: 8px;
    color: #7dcfff;
    padding: 4px 10px;
    font-size: 12px;
    font-weight: bold;
}

.sync-btn:hover {
    background-color: #004d6d;
    color: #cbe6ff;
}

.close-btn {
    background-color: transparent;
    border: none;
    color: #565f89;
    font-size: 16px;
    padding: 2px 6px;
}

.close-btn:hover {
    color: #ffb4ab;
}

.part-card {
    background-color: #1f2335;
    border: 1px solid #2f334d;
    border-radius: 12px;
    margin-bottom: 8px;
    padding: 8px 12px;
}

.part-header {
    padding: 4px 0;
}

.part-title {
    font-size: 13px;
    font-weight: bold;
    color: #c0caf5;
}

.part-badge {
    background-color: #24283b;
    border-radius: 6px;
    padding: 2px 8px;
    font-size: 11px;
    color: #7dcfff;
}

.part-chevron {
    background: transparent;
    border: none;
    color: #7dcfff;
    font-size: 13px;
    padding: 0 4px;
}

.chapter-box {
    padding: 2px 0 2px 28px;
}

.chapter-check {
    color: #c0caf5;
    font-size: 13px;
}

.chapter-check.completed {
    opacity: 0.6;
}

.lc-badge {
    background-color: #1f3340;
    border: 1px solid #7dcfff;
    border-radius: 6px;
    padding: 1px 6px;
    font-size: 11px;
    color: #7dcfff;
    font-weight: bold;
}

.lc-badge.all-done {
    background-color: #1a3328;
    border-color: #73daca;
    color: #73daca;
}

.prob-container {
    margin-left: 54px;
    padding: 4px 8px;
    background-color: #1a1b26;
    border-left: 2px solid #3b4261;
    border-radius: 0 8px 8px 0;
    margin-bottom: 4px;
}

.prob-row {
    padding: 2px 0;
}

.prob-btn {
    background: transparent;
    border: none;
    color: #565f89;
    font-size: 11px;
    padding: 0 4px;
}

.prob-btn:hover {
    color: #7dcfff;
}

checkbutton check {
    border-radius: 5px;
    border: 1px solid #565f89;
    background-color: #24283b;
    min-width: 16px;
    min-height: 16px;
}

checkbutton check:checked {
    background-color: #7dcfff;
    border-color: #7dcfff;
    color: #1a1b26;
}

.link-btn {
    background: transparent;
    border: none;
    color: #565f89;
    padding: 0 4px;
    font-size: 11px;
}

.link-btn:hover {
    color: #7dcfff;
}

.summary-card {
    background-color: #24283b;
    border: 1px solid #3b4261;
    border-radius: 12px;
    padding: 10px 14px;
    margin-top: 8px;
}

.summary-title {
    font-size: 13px;
    font-weight: bold;
    color: #bb9af7;
}

.summary-text {
    font-size: 12px;
    color: #a9b1d6;
}

scrollbar slider {
    background-color: #3b4261;
    border-radius: 6px;
    min-width: 6px;
}

scrollbar slider:hover {
    background-color: #7dcfff;
}
"""

class DSATrackerApp(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.set_name("dsa-tracker-window")
        self.get_style_context().add_class("dsa-window")

        self.data = self.load_data()
        self.state = self.load_state()
        self.lc_solved = self.load_leetcode()
        self.slugs = self.load_slugs()

        self.completed_set = set(self.state.get("completed_chapters", []))
        self.solved_ids = set(self.lc_solved.get("solved_ids", []))

        # Setup Layer Shell for Hyprland
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.TOP)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 48)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.ON_DEMAND)
        GtkLayerShell.set_namespace(self, "dsa-curriculum-tracker")

        self.set_default_size(800, 700)
        self.set_size_request(800, 700)

        self.setup_css()

        self.connect("key-press-event", self.on_key_press)
        self.connect("destroy", Gtk.main_quit)

        self.part_widgets = []
        self.chapter_widgets = []

        self.build_ui()
        self.apply_leetcode_auto_completion()
        self.update_all_stats()

        GLib.timeout_add_seconds(600, self.trigger_background_sync)

    def load_slugs(self):
        if not os.path.exists(SLUGS_FILE):
            return {}
        try:
            with open(SLUGS_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {}

    def load_data(self):
        if not os.path.exists(DATA_FILE):
            return []
        with open(DATA_FILE, "r") as f:
            return json.load(f)

    def load_state(self):
        if not os.path.exists(STATE_FILE):
            return {"completed_chapters": []}
        try:
            with open(STATE_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {"completed_chapters": []}

    def load_leetcode(self):
        if not os.path.exists(SOLVED_FILE):
            return {}
        try:
            with open(SOLVED_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {}

    def save_state(self):
        self.state["completed_chapters"] = sorted(list(self.completed_set))
        with open(STATE_FILE, "w") as f:
            json.dump(self.state, f, indent=2)
        self.notify_waybar()

    def notify_waybar(self):
        try:
            sig = signal.SIGRTMIN + 10
            pids = subprocess.check_output(["pidof", "waybar"]).decode().split()
            for p in pids:
                os.kill(int(p), sig)
        except Exception:
            pass

    def setup_css(self):
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        screen = Gdk.Screen.get_default()
        Gtk.StyleContext.add_provider_for_screen(screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

    def on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.hide()
            return True
        elif event.state & Gdk.ModifierType.CONTROL_MASK and event.keyval == Gdk.KEY_f:
            self.search_entry.grab_focus()
            return True
        return False

    def build_ui(self):
        root_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        root_box.get_style_context().add_class("main-container")
        self.add(root_box)

        # Header Box
        header_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        root_box.pack_start(header_box, False, False, 0)

        title_vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        title_lbl = Gtk.Label(xalign=0)
        title_lbl.set_markup('<span font="13" weight="bold" color="#7dcfff">󰉻 The DSA Handbook Curriculum</span>')
        self.stats_lbl = Gtk.Label(xalign=0)
        self.stats_lbl.get_style_context().add_class("header-stats")
        title_vbox.pack_start(title_lbl, False, False, 0)
        title_vbox.pack_start(self.stats_lbl, False, False, 0)
        header_box.pack_start(title_vbox, True, True, 0)

        # Sync button
        self.btn_sync = Gtk.Button(label="󰑐 Sync LeetCode")
        self.btn_sync.get_style_context().add_class("sync-btn")
        self.btn_sync.set_tooltip_text("Fetch latest solved questions from LeetCode account (the__ronakgupta)")
        self.btn_sync.connect("clicked", lambda b: self.run_sync_thread())
        header_box.pack_start(self.btn_sync, False, False, 0)

        # Controls
        btn_collapse = Gtk.Button(label="󰅂 Collapse")
        btn_collapse.get_style_context().add_class("action-btn")
        btn_collapse.connect("clicked", lambda b: self.set_all_expanded(False))
        header_box.pack_start(btn_collapse, False, False, 0)

        btn_expand = Gtk.Button(label="󰅃 Expand")
        btn_expand.get_style_context().add_class("action-btn")
        btn_expand.connect("clicked", lambda b: self.set_all_expanded(True))
        header_box.pack_start(btn_expand, False, False, 0)

        btn_close = Gtk.Button(label="✕")
        btn_close.get_style_context().add_class("close-btn")
        btn_close.connect("clicked", lambda b: self.hide())
        header_box.pack_start(btn_close, False, False, 0)

        # Progress bar
        self.progress_bar = Gtk.ProgressBar()
        self.progress_bar.set_margin_top(8)
        self.progress_bar.set_margin_bottom(8)
        root_box.pack_start(self.progress_bar, False, False, 0)

        # Search Bar
        search_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.search_entry = Gtk.SearchEntry()
        self.search_entry.set_placeholder_text("Search chapters, topics (e.g. dynamic programming, binary search, graph)...")
        self.search_entry.connect("search-changed", self.on_search_changed)
        search_box.pack_start(self.search_entry, True, True, 0)
        root_box.pack_start(search_box, False, False, 0)

        # Scrolled content
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scrolled.set_min_content_height(480)
        scrolled.set_margin_top(10)
        root_box.pack_start(scrolled, True, True, 0)

        self.parts_container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        scrolled.add(self.parts_container)

        for p_idx, part in enumerate(self.data):
            self.create_part_card(part, p_idx)

        self.create_summary_card(root_box)

    def create_part_card(self, part, p_idx):
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        card.get_style_context().add_class("part-card")
        self.parts_container.pack_start(card, False, False, 0)

        head_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        head_box.get_style_context().add_class("part-header")
        card.pack_start(head_box, False, False, 0)

        btn_chevron = Gtk.Button(label="▾")
        btn_chevron.get_style_context().add_class("part-chevron")
        head_box.pack_start(btn_chevron, False, False, 0)

        part_check = Gtk.CheckButton()
        part_check_label = Gtk.Label(xalign=0)
        part_check_label.set_markup(f'<span font="11" weight="bold" color="#c0caf5">{part["title"]}</span>')
        part_check.add(part_check_label)
        head_box.pack_start(part_check, True, True, 0)

        part_badge = Gtk.Label()
        part_badge.get_style_context().add_class("part-badge")
        head_box.pack_start(part_badge, False, False, 0)

        revealer = Gtk.Revealer()
        revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN)
        revealer.set_reveal_child(True)
        card.pack_start(revealer, False, False, 0)

        chapters_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        revealer.add(chapters_box)

        def toggle_revealer(b):
            is_open = revealer.get_reveal_child()
            revealer.set_reveal_child(not is_open)
            btn_chevron.set_label("▾" if not is_open else "▸")
        btn_chevron.connect("clicked", toggle_revealer)

        part_record = {
            "part": part,
            "check": part_check,
            "badge": part_badge,
            "revealer": revealer,
            "chevron": btn_chevron,
            "card": card,
            "updating_from_children": False,
            "chapter_records": []
        }
        self.part_widgets.append(part_record)

        for ch in part["chapters"]:
            ch_vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            chapters_box.pack_start(ch_vbox, False, False, 0)

            ch_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
            ch_row.get_style_context().add_class("chapter-box")
            ch_vbox.pack_start(ch_row, False, False, 0)

            ch_check = Gtk.CheckButton(label=f"  {ch['full_label']}")
            ch_check.get_style_context().add_class("chapter-check")
            ch_check.set_active(ch["num"] in self.completed_set)
            ch_row.pack_start(ch_check, True, True, 0)

            lc_badge = Gtk.Label()
            lc_badge.get_style_context().add_class("lc-badge")
            ch_row.pack_start(lc_badge, False, False, 0)

            prob_revealer = None
            if ch.get("items"):
                btn_prob_toggle = Gtk.Button(label="Problems ▾")
                btn_prob_toggle.get_style_context().add_class("prob-btn")
                btn_prob_toggle.set_tooltip_text("Show / hide practice problems list")
                ch_row.pack_start(btn_prob_toggle, False, False, 0)

                prob_revealer = Gtk.Revealer()
                prob_revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN)
                prob_revealer.set_reveal_child(False)
                ch_vbox.pack_start(prob_revealer, False, False, 0)

                prob_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
                prob_box.get_style_context().add_class("prob-container")
                prob_revealer.add(prob_box)

                def toggle_prob_view(b, r=prob_revealer, btn=btn_prob_toggle, pbox=prob_box, chapter=ch):
                    if not pbox.get_children():
                        probs = chapter.get("problems", [])
                        if not probs:
                            for it in chapter.get("items", []):
                                m = re.search(r'LC\s*(\d+)', it)
                                qid = m.group(1) if m else None
                                slug = self.slugs.get(qid, "")
                                probs.append({
                                    "id": qid,
                                    "title": it,
                                    "slug": slug,
                                    "url": f"https://leetcode.com/problems/{slug}/" if slug else "https://leetcode.com/",
                                    "difficulty": "Easy" if "Easy" in it else ("Medium" if "Medium" in it else "Hard"),
                                    "is_star": "★" in it
                                })

                        for p in probs:
                            lc_id = p.get("id")
                            slug = p.get("slug") or self.slugs.get(lc_id, "")
                            is_solved = lc_id in self.solved_ids if lc_id else False
                            target_url = p.get("url") or (f"https://leetcode.com/problems/{slug}/" if slug else "https://leetcode.com/")

                            p_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
                            p_row.get_style_context().add_class("prob-row")
                            pbox.pack_start(p_row, False, False, 0)

                            status_icon = "✓" if is_solved else "○"
                            status_color = "#73daca" if is_solved else "#565f89"
                            diff = p.get("difficulty", "")
                            diff_color = "#73daca" if diff == "Easy" else ("#ffbb55" if diff == "Medium" else "#ff757f")
                            star = "★ " if p.get("is_star") else ""

                            p_lbl = Gtk.Label(xalign=0)
                            p_markup = f'<span color="{status_color}" weight="bold">{status_icon}</span> <span color="#7dcfff">{star}LC {lc_id}:</span> <span color="{"#c0caf5" if is_solved else "#a9b1d6"}">{p.get("title", "")}</span>'
                            if diff:
                                p_markup += f' <span color="{diff_color}">[{diff}]</span>'
                            if is_solved:
                                p_markup += ' <span color="#73daca" size="small">(Solved)</span>'
                            p_lbl.set_markup(p_markup)
                            p_row.pack_start(p_lbl, True, True, 0)

                            btn_lc = Gtk.Button(label="Solve 󰌹")
                            btn_lc.get_style_context().add_class("prob-btn")
                            btn_lc.set_tooltip_text(f"Open {target_url} directly on LeetCode")
                            btn_lc.connect("clicked", lambda b, u=target_url: webbrowser.open(u))
                            p_row.pack_start(btn_lc, False, False, 0)

                        pbox.show_all()

                    open_state = r.get_reveal_child()
                    r.set_reveal_child(not open_state)
                    btn.set_label("Problems ▾" if open_state else "Problems ▴")

                btn_prob_toggle.connect("clicked", toggle_prob_view)

            btn_open = Gtk.Button(label="󰌹 Open")
            btn_open.get_style_context().add_class("link-btn")
            btn_open.set_tooltip_text(f"Open {ch['title']} in handbook")
            btn_open.connect("clicked", lambda b, u=ch["url"]: webbrowser.open(u))
            ch_row.pack_start(btn_open, False, False, 0)

            ch_record = {
                "chapter": ch,
                "check": ch_check,
                "row": ch_vbox,
                "lc_badge": lc_badge,
                "prob_revealer": prob_revealer,
                "part_record": part_record
            }
            part_record["chapter_records"].append(ch_record)
            self.chapter_widgets.append(ch_record)

            def on_ch_toggled(chk, cr=ch_record):
                num = cr["chapter"]["num"]
                if chk.get_active():
                    self.completed_set.add(num)
                    cr["check"].get_style_context().add_class("completed")
                else:
                    self.completed_set.discard(num)
                    cr["check"].get_style_context().remove_class("completed")
                self.save_state()
                self.update_part_state(cr["part_record"])
                self.update_all_stats()

            ch_check.connect("toggled", on_ch_toggled)
            if ch["num"] in self.completed_set:
                ch_check.get_style_context().add_class("completed")

        def on_part_toggled(chk, pr=part_record):
            if pr.get("updating_from_children", False):
                return
            target_state = chk.get_active()
            for cr in pr["chapter_records"]:
                if cr["check"].get_active() != target_state:
                    cr["check"].set_active(target_state)

        part_check.connect("toggled", on_part_toggled)

    def create_summary_card(self, root_box):
        summary_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=16)
        summary_box.get_style_context().add_class("summary-card")
        root_box.pack_start(summary_box, False, False, 0)

        t_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        summary_box.pack_start(t_box, True, True, 0)

        s_title = Gtk.Label(xalign=0)
        s_title.set_markup('<span font="10" weight="bold" color="#bb9af7">Curriculum Overview</span>')
        t_box.pack_start(s_title, False, False, 0)

        self.summary_desc = Gtk.Label(xalign=0)
        t_box.pack_start(self.summary_desc, False, False, 0)

        btn_reset = Gtk.Button(label="󰑐 Reset All")
        btn_reset.get_style_context().add_class("action-btn")
        btn_reset.connect("clicked", self.on_reset_clicked)
        summary_box.pack_start(btn_reset, False, False, 0)

    def apply_leetcode_auto_completion(self):
        changed = False
        for cr in self.chapter_widgets:
            ch = cr["chapter"]
            prob_ids = []
            for it in ch.get("items", []):
                m = re.search(r'LC\s*(\d+)', it)
                if m:
                    prob_ids.append(m.group(1))

            if prob_ids:
                all_solved = all(pid in self.solved_ids for pid in prob_ids)
                if all_solved and ch["num"] not in self.completed_set:
                    self.completed_set.add(ch["num"])
                    cr["check"].set_active(True)
                    cr["check"].get_style_context().add_class("completed")
                    changed = True

        if changed:
            self.save_state()

    def run_sync_thread(self):
        self.btn_sync.set_label("󰑐 Syncing...")
        self.btn_sync.set_sensitive(False)

        def worker():
            subprocess.run(["/usr/bin/python3", SYNC_SCRIPT], capture_output=True)
            GLib.idle_add(self.on_sync_finished)

        threading.Thread(target=worker, daemon=True).start()

    def trigger_background_sync(self):
        threading.Thread(target=lambda: subprocess.run(["/usr/bin/python3", SYNC_SCRIPT], capture_output=True), daemon=True).start()
        return True

    def on_sync_finished(self):
        self.btn_sync.set_label("󰑐 Sync LeetCode")
        self.btn_sync.set_sensitive(True)

        self.lc_solved = self.load_leetcode()
        self.solved_ids = set(self.lc_solved.get("solved_ids", []))
        self.state = self.load_state()
        self.completed_set = set(self.state.get("completed_chapters", []))

        self.apply_leetcode_auto_completion()
        self.update_all_stats()

    def on_reset_clicked(self, btn):
        dialog = Gtk.MessageDialog(
            transient_for=self,
            flags=0,
            message_type=Gtk.MessageType.QUESTION,
            buttons=Gtk.ButtonsType.YES_NO,
            text="Reset DSA Curriculum Progress?"
        )
        dialog.format_secondary_text("Are you sure you want to uncheck all chapters and reset your progress?")
        res = dialog.run()
        dialog.destroy()
        if res == Gtk.ResponseType.YES:
            self.completed_set.clear()
            for cr in self.chapter_widgets:
                cr["check"].set_active(False)
                cr["check"].get_style_context().remove_class("completed")
            self.save_state()
            for pr in self.part_widgets:
                self.update_part_state(pr)
            self.update_all_stats()

    def set_all_expanded(self, expanded):
        for pr in self.part_widgets:
            pr["revealer"].set_reveal_child(expanded)
            pr["chevron"].set_label("▾" if expanded else "▸")

    def on_search_changed(self, entry):
        query = entry.get_text().strip().lower()
        for pr in self.part_widgets:
            any_visible = False
            for cr in pr["chapter_records"]:
                ch_text = (cr["chapter"]["title"] + " " + cr["chapter"]["num"] + " " + cr["chapter"]["full_label"]).lower()
                matches = query in ch_text if query else True
                cr["row"].set_visible(matches)
                if matches:
                    any_visible = True
            part_title_match = query in pr["part"]["title"].lower() if query else True
            if part_title_match:
                any_visible = True
                for cr in pr["chapter_records"]:
                    cr["row"].set_visible(True)
            pr["card"].set_visible(any_visible)
            if query and any_visible:
                pr["revealer"].set_reveal_child(True)
                pr["chevron"].set_label("▾")

    def update_part_state(self, pr):
        total_ch = len(pr["chapter_records"])
        done_ch = sum(1 for cr in pr["chapter_records"] if cr["chapter"]["num"] in self.completed_set)
        total_q = pr["part"]["total_questions"]

        done_q = 0
        for cr in pr["chapter_records"]:
            ch = cr["chapter"]
            is_ch_done = ch["num"] in self.completed_set
            ch_prob_ids = [re.search(r'LC\s*(\d+)', it).group(1) for it in ch.get("items", []) if re.search(r'LC\s*(\d+)', it)]
            solved_in_ch = sum(1 for pid in ch_prob_ids if pid in self.solved_ids)

            if is_ch_done:
                done_q += ch["q_count"]
            else:
                done_q += solved_in_ch

            if ch_prob_ids:
                if solved_in_ch == len(ch_prob_ids):
                    cr["lc_badge"].set_markup(f'<span color="#73daca"><b>{solved_in_ch}/{len(ch_prob_ids)} LC ★</b></span>')
                    cr["lc_badge"].get_style_context().add_class("all-done")
                    cr["lc_badge"].set_visible(True)
                elif solved_in_ch > 0:
                    cr["lc_badge"].set_markup(f'<span color="#7dcfff">{solved_in_ch}/{len(ch_prob_ids)} LC</span>')
                    cr["lc_badge"].get_style_context().remove_class("all-done")
                    cr["lc_badge"].set_visible(True)
                else:
                    cr["lc_badge"].set_visible(False)
            else:
                cr["lc_badge"].set_visible(False)

        pr["badge"].set_text(f"{done_ch}/{total_ch} ch · {done_q}/{total_q} Qs")

        pr["updating_from_children"] = True
        all_done = (done_ch == total_ch and total_ch > 0)
        pr["check"].set_active(all_done)
        pr["updating_from_children"] = False

    def update_all_stats(self):
        for pr in self.part_widgets:
            self.update_part_state(pr)

        total_ch = len(self.chapter_widgets)
        done_ch = len(self.completed_set)
        total_q = sum(cr["chapter"]["q_count"] for cr in self.chapter_widgets)

        done_q = 0
        for cr in self.chapter_widgets:
            ch = cr["chapter"]
            if ch["num"] in self.completed_set:
                done_q += ch["q_count"]
            else:
                ch_prob_ids = [re.search(r'LC\s*(\d+)', it).group(1) for it in ch.get("items", []) if re.search(r'LC\s*(\d+)', it)]
                done_q += sum(1 for pid in ch_prob_ids if pid in self.solved_ids)

        ch_pct = (done_ch / total_ch * 100) if total_ch > 0 else 0
        q_pct = (done_q / total_q * 100) if total_q > 0 else 0

        lc_user = self.lc_solved.get("username", "the__ronakgupta")
        lc_total = self.lc_solved.get("total_solved", 0)

        self.stats_lbl.set_markup(
            f'<b>LeetCode:</b> <span color="#73daca" weight="bold">{lc_user}</span> ({lc_total} solved)  ·  '
            f'<b>Questions:</b> <span color="#7dcfff">{done_q}/{total_q}</span> ({q_pct:.1f}%)  ·  '
            f'<b>Chapters:</b> <span color="#bb9af7">{done_ch}/{total_ch}</span> ({ch_pct:.1f}%)'
        )
        self.progress_bar.set_fraction(q_pct / 100.0)

        self.summary_desc.set_markup(
            f'<span font="9" color="#a9b1d6">15 Parts · 120 Chapters · 437 Total Questions (396 Unique) · '
            f'<span color="#7dcfff">{done_q} Questions Completed</span></span>'
        )

# Global reference for socket server
APP_HOLDER = [None]

def run_socket_server():
    if os.path.exists(SOCK_PATH):
        try:
            os.remove(SOCK_PATH)
        except Exception:
            pass

    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(SOCK_PATH)
    server.listen(5)

    while True:
        try:
            conn, _ = server.accept()
            data = conn.recv(1024).decode().strip()
            app = APP_HOLDER[0]
            if app:
                if data == "toggle":
                    GLib.idle_add(lambda a=app: a.hide() if a.is_visible() else (a.show_all(), a.present()))
                elif data == "show":
                    GLib.idle_add(lambda a=app: (a.show_all(), a.present()))
                elif data == "hide":
                    GLib.idle_add(app.hide)
                elif data == "quit":
                    GLib.idle_add(Gtk.main_quit)
                    break
            conn.close()
        except Exception:
            break

def send_socket_command(cmd):
    if not os.path.exists(SOCK_PATH):
        return False
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.settimeout(0.8)
        s.connect(SOCK_PATH)
        s.sendall(cmd.encode() + b"\n")
        s.close()
        return True
    except Exception:
        return False

def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "toggle"

    if action in ("toggle", "show", "hide", "quit"):
        if send_socket_command(action):
            sys.exit(0)
        if action in ("hide", "quit"):
            sys.exit(0)

        subprocess.Popen(["/usr/bin/python3", os.path.abspath(__file__), "app"],
                         stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        sys.exit(0)

    elif action == "app":
        # Start socket thread immediately so toggling is responsive from the get-go
        sock_thread = threading.Thread(target=run_socket_server, daemon=True)
        sock_thread.start()

        app = DSATrackerApp()
        APP_HOLDER[0] = app
        app.show_all()

        def signal_handler(sig, frame):
            GLib.idle_add(Gtk.main_quit)
        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)

        Gtk.main()

        if os.path.exists(SOCK_PATH):
            try:
                os.remove(SOCK_PATH)
            except Exception:
                pass

if __name__ == "__main__":
    main()
