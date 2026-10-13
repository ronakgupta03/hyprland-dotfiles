# Neovim (VS Code Style) Keybind Guide

The **Leader key** is **`Space`** (`<leader>`).  
Press and release `Space`, then press the subsequent keys.

---

## 1. VS Code Muscle Memory

| Action | Neovim Keybind | VS Code Equivalent | Example |
| :--- | :--- | :--- | :--- |
| **Quick Open File** | `<C-p>` or `<leader><space>` | `Ctrl+P` | Press `Ctrl+P`, type `app.py`, hit `Enter`. |
| **Toggle Sidebar / Tree** | `<C-b>` or `<C-n>` or `<leader>e` | `Ctrl+B` | Press `Ctrl+b` to hide or show your project files. |
| **Toggle Terminal** | `<C-\>` or ``<C-`>`` | `Ctrl+`` | Press `Ctrl+\` to open a terminal drawer at the bottom. |
| **Global Text Search** | `<leader>sg` | `Ctrl+Shift+F` | Press `Space s g`, type `import torch`, see all matches across files. |
| **Command Palette** | `<leader>:` | `Ctrl+Shift+P` | Press `Space :` to run Neovim `:commands` with fuzzy autocomplete. |
| **Save File** | `<leader>w` or `:w` | `Ctrl+S` | Press `Space w` to save changes. |

---

## 2. File Explorer (`neo-tree.nvim`)

Open or toggle with `<C-b>`, `<C-n>`, or `<leader>e`. When the tree sidebar is focused:

| Key | What it does | Example |
| :--- | :--- | :--- |
| `Enter` or `l` | Open file or expand folder | Press `Enter` on a folder to expand it. |
| `h` | Collapse folder | Press `h` on an expanded folder to collapse it. |
| `a` | **Add** file or folder | Press `a`, type `src/utils.py` (folders auto-create if needed). |
| `d` | **Delete** file/folder | Press `d`, confirm with `y` to delete. |
| `r` | **Rename** file/folder | Press `r`, edit the name, hit `Enter`. |
| `c` | **Copy** file | Press `c`, enter target destination name. |
| `m` | **Move / Cut** file | Press `m`, enter new directory path. |
| `y` | Copy file path to clipboard | Press `y` on any file. |
| `q` | Close sidebar | Returns focus back to your code. |

---

## 3. Fuzzy Finding & Navigation (`telescope.nvim`)

All search commands start with `<leader>f` (files) or `<leader>s` (search):

| Keybind | What it searches | Example |
| :--- | :--- | :--- |
| `<leader>ff` | Search files by name | `Space f f` → type `main` → jump directly to `main.cpp`. |
| `<leader>sg` | Search code contents (Live Grep) | `Space s g` → type `def calculate` → find where function is defined or called. |
| `<leader>fb` | Active tabs / buffers | `Space f b` → switch between files currently opened in memory. |
| `<leader>fr` | Recent files | `Space f r` → pick from files you worked on earlier. |
| `<leader>sw` | Search word under cursor | Place cursor on `UserSession`, press `Space s w` to find all occurrences. |

**Inside any Telescope search window:**
- Move up / down: `Ctrl+n` / `Ctrl+p` (or arrow keys).
- Open file: `Enter`.
- Open in horizontal split: `Ctrl+x`.
- Open in vertical split: `Ctrl+v`.
- Cancel / Exit: `Esc`.

---

## 4. Code Completion (`blink.cmp`)

The completion menu appears automatically as you type code.

| Key | Action |
| :--- | :--- |
| `Enter` or `<C-y>` | Accept the highlighted suggestion. |
| `<C-n>` / `<C-p>` | Move down / up in the suggestion list. |
| `<Tab>` | Jump forward inside snippet parameters (or accept completion). |
| `<S-Tab>` | Jump backward inside snippet parameters. |
| `<C-space>` | Manually trigger the completion popup if closed. |

---

## 5. Code Intelligence & Refactoring (LSP + `mason.nvim`)

| Keybind | What it does | VS Code Equivalent | Example |
| :--- | :--- | :--- | :--- |
| `gd` | **Go to Definition** | `F12` | Put cursor on `MyClass()` and hit `gd` to jump to its source. |
| `gr` | **Find References** | `Shift+F12` | Hit `gr` to open a Telescope list of every place this variable is used. |
| `K` | **Hover Documentation** | Mouse hover | Shows docstring, parameter types, and function signature. |
| `<leader>cr` | **Rename Symbol** | `F2` | Press `Space c r`, type the new variable name, and it updates across files. |
| `<leader>ca` | **Code Actions / Quick Fix** | `Ctrl+.` | Fix imports, auto-apply linter fixes. |
| `<leader>cf` | **Format Code** | `Shift+Alt+F` | Formats current file with Prettier, Black, Clang-format, etc. |
| `]d` / `[d` | **Next / Previous Warning** | `F8` | Cycle directly to the next syntax error or warning. |

---

## 6. Problems & Diagnostics (`trouble.nvim`)

| Keybind | What it does |
| :--- | :--- |
| `<leader>xx` | Toggle the Problems / Diagnostics list (whole project). |
| `<leader>xX` | Toggle diagnostics for the current file only. |
| `<leader>cs` | Document symbols outline (see classes and functions in current file). |
| `<leader>xL` | Location list / Quickfix list. |
| `q` | Close the Trouble panel. |

---

## 7. Integrated Terminal (`toggleterm.nvim`)

| Keybind | Mode | Action |
| :--- | :--- | :--- |
| `<C-\>` or ``<C-`>`` | Normal / Insert | Toggle terminal drawer at bottom (size 15 lines). |
| `<C-\>` or ``<C-`>`` | Terminal mode | Hide terminal (process keeps running in background). |
| `<C-\><C-n>` | Terminal mode | Switch to Neovim Normal mode inside terminal (allows scrolling, selecting, copying output). |

---

## 8. Git Gutters & Diff (`gitsigns.nvim`)

Gutter indicators: green bars = added lines, blue bars = modified lines, red triangles = deleted lines.

| Keybind | Action | Example |
| :--- | :--- | :--- |
| `]h` / `[h` | Jump to next / previous git change. | Skip directly between modified sections. |
| `<leader>ghp` | Preview hunk diff inline. | View what was deleted/changed without opening git diff. |
| `<leader>ghs` | Stage current hunk. | Stage just these few lines for commit. |
| `<leader>ghr` | Reset / undo current hunk. | Revert edits on the current block back to git HEAD. |
| `<leader>gb` | Git Blame line. | See who committed this line and when. |

---

## 9. C++ Compile & Run (`<leader>rr`)

| Keybind | Action | Example |
| :--- | :--- | :--- |
| `<leader>rr` | **Save, compile (`g++ -O2 -std=c++17`), run in bottom split** | Press `Space r r` on `sol.cpp` → binary `/tmp/cp_sol`, output in split terminal. |

Drop an `input.txt` next to your `.cpp` → auto-fed via `< input.txt`.
---

## 11. Snippets (VS Code-style, `LuaSnip`)
---
## 12. Split Windows & Buffer Tabs

- **Tab Bar (top of screen):**
  - `<S-h>` or `[b`: Switch to previous file tab.
  - `<S-l>` or `]b`: Switch to next file tab.
  - `<leader>bd`: Close current tab / buffer.
- **Window Navigation (between split panes):**
  - `Ctrl+h`: Focus left window.
  - `Ctrl+j`: Focus bottom window.
  - `Ctrl+k`: Focus top window.
  - `Ctrl+l`: Focus right window.
- **Split Management:**
  - `<leader>w-` or `Ctrl+w s`: Split horizontally.
  - `<leader>w|` or `Ctrl+w v`: Split vertically.
  - `<leader>wd` or `Ctrl+w c`: Close split window.

> **Tip:** Whenever you forget a keybind, press **`Space`** and pause half a second. **Which-Key** will open an interactive cheatsheet at the bottom showing every available key.
