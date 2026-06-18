#!/usr/bin/env python3
"""
Competitive Companion listener.
Fetches rating from CF API, creates per-problem subfolder, auto-opens nvim in WezTerm.
"""
import json
import os
import shlex
import shutil
import subprocess
import sys
import urllib.request
from http.server import HTTPServer, BaseHTTPRequestHandler

TEMPLATE = os.path.expanduser("~/C++/CompetitiveProgramming/templates/template.cpp")
CF_BASE  = os.path.expanduser("~/C++/CompetitiveProgramming/Codeforces")


def rating_folder(rating):
    if rating is None:   return "inbox"
    if rating <= 1000:   return "rating_800_1000"
    if rating <= 1300:   return "rating_1100_1300"
    if rating <= 1600:   return "rating_1400_1600"
    if rating <= 1900:   return "rating_1700_1900"
    return "rating_2000_plus"


def fetch_rating(contest_id, index):
    try:
        url = "https://codeforces.com/api/problemset.problems"
        with urllib.request.urlopen(url, timeout=5) as r:
            data = json.loads(r.read())
        if data.get("status") != "OK":
            return None
        for p in data["result"]["problems"]:
            if str(p.get("contestId")) == str(contest_id) and p.get("index") == index:
                return p.get("rating")
    except Exception:
        pass
    return None


def parse_problem(url):
    parts = url.rstrip("/").split("/")
    try:
        if "problemset" in url:
            return parts[-2], parts[-1]
        elif "contest" in url:
            return parts[-3], parts[-1]
    except Exception:
        pass
    return None, None


def open_in_wezterm(cpp_file, notes_file):
    cmd = f"nvim {shlex.quote(cpp_file)}"
    if shutil.which("wezterm"):
        subprocess.Popen(["wezterm", "cli", "spawn", "--", "bash", "-lc", cmd])
    elif shutil.which("tmux"):
        subprocess.Popen(["tmux", "new-window", "-n", os.path.basename(cpp_file), cmd])


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers["Content-Length"])
        data   = json.loads(self.rfile.read(length))
        url    = data.get("url", "")
        tests  = data.get("tests", [])

        contest_id, index = parse_problem(url)
        pid = (contest_id or "?") + (index or "?")

        print(f"\n→ {pid}: fetching rating...", flush=True)
        rating  = fetch_rating(contest_id, index) if contest_id else None
        folder  = rating_folder(rating)

        dest      = os.path.join(CF_BASE, folder, pid)
        test_dir  = os.path.join(dest, "test")
        cpp_file  = os.path.join(dest, f"{pid}.cpp")
        meta_file = os.path.join(dest, f"{pid}.meta")
        notes_file= os.path.join(dest, f"{pid}_notes.md")

        os.makedirs(test_dir, exist_ok=True)

        if not os.path.exists(cpp_file):
            with open(os.path.expanduser(TEMPLATE)) as f:
                template = f.read()
            with open(cpp_file, "w") as f:
                f.write(template)

        with open(meta_file, "w") as f:
            f.write(url)

        if not os.path.exists(notes_file):
            with open(notes_file, "w") as f:
                f.write(
                    "<!-- Keybindings: Space+cT (test) | Space+cS (submit) | Space+cC (commit) | Ctrl+w w (switch pane) | Ctrl+w > / < (resize) -->\n\n"
                    f"# {pid}\n\n"
                    "## Thought Process\n\n"
                    "## Approach\n\n"
                    "## Edge Cases\n\n"
                    "## Complexity\n\n"
                    "## Attempts\n"
                )

        for i, test in enumerate(tests, 1):
            with open(os.path.join(test_dir, f"sample-{i}.in"),  "w") as f:
                f.write(test["input"])
            with open(os.path.join(test_dir, f"sample-{i}.out"), "w") as f:
                f.write(test["output"])

        rating_str = str(rating) if rating else "unknown"
        print(f"✓  {pid} (rating {rating_str}) → {folder}/{pid}")
        print(f"   opening nvim...", flush=True)

        open_in_wezterm(cpp_file, notes_file)

        self.send_response(200)
        self.end_headers()

    def log_message(self, *_):
        pass


if __name__ == "__main__":
    print("CP listener :10043 — click Competitive Companion on any CF problem\n")
    HTTPServer(("localhost", 10043), Handler).serve_forever()
