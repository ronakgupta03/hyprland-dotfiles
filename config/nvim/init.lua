-- rice-theme-reload socket
if vim.env.XDG_RUNTIME_DIR and vim.uv.fs_stat(vim.env.XDG_RUNTIME_DIR) then
  pcall(vim.fn.serverstart, vim.env.XDG_RUNTIME_DIR .. ("/nvim.%d.0"):format(vim.fn.getpid()))
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure LazyVim distro and requested plugins
require("lazy").setup({
  spec = {
    -- LazyVim base distro (includes mason.nvim, nvim-lspconfig, trouble.nvim, gitsigns.nvim)
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = "matugen",
      },
    },

    -- Extras: neo-tree, blink.cmp, telescope, luasnip
    { import = "lazyvim.plugins.extras.editor.neo-tree" },
    { import = "lazyvim.plugins.extras.coding.blink" },
    { import = "lazyvim.plugins.extras.editor.telescope" },
    { import = "lazyvim.plugins.extras.coding.luasnip" },

    -- Integrated terminal (VS Code style toggle)
    {
      "akinsho/toggleterm.nvim",
      version = "*",
      cmd = { "ToggleTerm", "TermExec" },
      opts = {
        open_mapping = [[<c-\>]],
        direction = "horizontal",
        size = 15,
      },
      keys = {
        { [[<c-\>]], "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
        { "<c-`>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
      },
    },
    -- CP completion: snippets instant, LSP fires on . -> ::
    {
      "saghen/blink.cmp",
      opts = {
        snippets = { score_offset = 10 },
        sources = {
          default = { "snippets", "lsp", "buffer", "path" },
          min_keyword_length = 0,
          providers = {
            snippets = { min_keyword_length = 1, score_offset = 10 },
            lsp = { min_keyword_length = 0 },
            buffer = { min_keyword_length = 3 },
          },
        },
        completion = {
          trigger = { show_on_trigger_character = true, show_on_keyword = true, show_on_insert_on_trigger_character = true },
          list = { selection = { preselect = false, auto_insert = false } },
          ghost_text = { enabled = false },
          documentation = { auto_show = false },
        },
        signature = { enabled = false },
      },
    },
    {
      "neovim/nvim-lspconfig",
      opts = {
        inlay_hints = { enabled = false },
        servers = {
          clangd = {
            root_markers = { ".git" },
            mason = false,
            cmd = {
              "clangd",
              "--header-insertion=never",
              "--completion-style=bundled",
              "--function-arg-placeholders=false",
            },
          },
        },
      },
    },
  },
  defaults = { lazy = false, version = false },
})


-- CP: compile + run C++ (<leader>rr), feeds input.txt if present
vim.keymap.set("n", "<leader>rr", function()
  vim.cmd("w")
  local file = vim.fn.expand("%:p")
  local out = "/tmp/cp_" .. vim.fn.expand("%:t:r")
  local cmd = "g++ -std=c++17 -O2 -o "
    .. vim.fn.shellescape(out)
    .. " "
    .. vim.fn.shellescape(file)
    .. " && "
    .. vim.fn.shellescape(out)
  local input = vim.fn.expand("%:p:h") .. "/input.txt"
  if vim.fn.filereadable(input) == 1 then
    cmd = cmd .. " < " .. vim.fn.shellescape(input)
  end
  vim.cmd("botright 12split | term " .. cmd)
  vim.cmd("startinsert")
end, { desc = "Compile & Run C++" })
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<C-n>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neo-tree" })
vim.keymap.set("n", "<C-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Sidebar" })
