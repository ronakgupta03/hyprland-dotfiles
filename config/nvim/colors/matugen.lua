-- matugen colorscheme: Material You palette generated from the wallpaper.
-- Palette lives in ~/.cache/nvim/matugen-colors.lua, written by matugen
-- (template ~/.config/matugen/templates/nvim-colors.lua). Retheme by
-- changing the wallpaper; running instances reload via rice-theme-reload.
local ok, palette = pcall(dofile, vim.fn.stdpath("cache") .. "/matugen-colors.lua")
if not ok or type(palette) ~= "table" then
    -- No generated palette (fresh install before first matugen run): fall back.
    vim.notify("matugen: palette not found, run `rice-wallpaper theme`", vim.log.levels.WARN)
    return
end

local c = palette

vim.g.terminal_color_0  = c.bg_high
vim.g.terminal_color_8  = c.outline
vim.g.terminal_color_1  = c.error
vim.g.terminal_color_9  = c.error
vim.g.terminal_color_2  = c.tertiary
vim.g.terminal_color_10 = c.tertiary_d
vim.g.terminal_color_3  = c.secondary
vim.g.terminal_color_11 = c.secondary_d
vim.g.terminal_color_4  = c.primary
vim.g.terminal_color_12 = c.primary
vim.g.terminal_color_5  = c.on_pcont
vim.g.terminal_color_13 = c.pcontainer
vim.g.terminal_color_6  = c.tertiary_c
vim.g.terminal_color_14 = c.tertiary_d
vim.g.terminal_color_7  = c.fg_dim
vim.g.terminal_color_15 = c.fg

local hi = function(group, spec) vim.api.nvim_set_hl(0, group, spec) end

-- Base
hi("Normal",       { fg = c.fg,      bg = c.bg })
hi("NormalFloat",  { fg = c.fg,      bg = c.bg_float })
hi("FloatBorder",  { fg = c.outline, bg = c.bg_float })
hi("FloatTitle",   { fg = c.on_pcont, bg = c.pcontainer, bold = true })
hi("Cursor",       { fg = c.on_primary, bg = c.primary })
hi("CursorLine",   { bg = c.bg_high })
hi("CursorColumn", { bg = c.bg_high })
hi("ColorColumn",  { bg = c.bg_high })
hi("LineNr",       { fg = c.outline })
hi("CursorLineNr", { fg = c.primary, bold = true })
hi("SignColumn",   { fg = c.fg_dim, bg = c.bg })
hi("VertSplit",    { fg = c.divider })
hi("WinSeparator", { fg = c.divider })
hi("Visual",       { bg = c.pcontainer })
hi("Search",       { fg = c.on_primary, bg = c.primary })
hi("CurSearch",    { fg = c.on_primary, bg = c.primary, bold = true })
hi("IncSearch",    { fg = c.on_primary, bg = c.primary })
hi("Substitute",   { fg = c.on_primary, bg = c.primary })
hi("MatchParen",   { fg = c.primary, bold = true, underline = true })
hi("Pmenu",        { fg = c.fg,      bg = c.bg_float })
hi("PmenuSel",     { fg = c.on_pcont, bg = c.pcontainer })
hi("PmenuSbar",    { bg = c.bg_float })
hi("PmenuThumb",   { bg = c.outline })
hi("StatusLine",   { fg = c.fg,      bg = c.bg_high })
hi("StatusLineNC", { fg = c.fg_dim,  bg = c.bg_float })
hi("TabLine",      { fg = c.fg_dim,  bg = c.bg_float })
hi("TabLineSel",   { fg = c.on_pcont, bg = c.pcontainer, bold = true })
hi("TabLineFill",  { bg = c.bg })
hi("WinBar",       { fg = c.fg_dim })
hi("WinBarNC",     { fg = c.outline })
hi("Folded",       { fg = c.fg_dim,  bg = c.bg_high })
hi("FoldColumn",   { fg = c.outline })
hi("EndOfBuffer",  { fg = c.bg })
hi("NonText",      { fg = c.outline })
hi("Whitespace",   { fg = c.divider })
hi("Conceal",      { fg = c.fg_dim })
hi("QuickFixLine", { bg = c.bg_high })
hi("Directory",    { fg = c.primary })
hi("Title",        { fg = c.primary, bold = true })
hi("ErrorMsg",     { fg = c.error, bold = true })
hi("ModeMsg",      { fg = c.fg_dim })
hi("MoreMsg",      { fg = c.tertiary })
hi("Question",     { fg = c.tertiary })
hi("WarningMsg",   { fg = c.secondary })
hi("SpecialKey",   { fg = c.outline })

-- Syntax
hi("Comment",      { fg = c.outline, italic = true })
hi("Constant",     { fg = c.tertiary })
hi("String",       { fg = c.tertiary })
hi("Character",    { fg = c.tertiary })
hi("Number",       { fg = c.tertiary })
hi("Boolean",      { fg = c.tertiary })
hi("Float",        { fg = c.tertiary })
hi("Identifier",   { fg = c.secondary })
hi("Function",     { fg = c.primary })
hi("Statement",    { fg = c.primary })
hi("Conditional",  { fg = c.primary })
hi("Repeat",       { fg = c.primary })
hi("Label",        { fg = c.primary })
hi("Operator",     { fg = c.fg_dim })
hi("Keyword",      { fg = c.primary })
hi("Exception",    { fg = c.primary })
hi("PreProc",      { fg = c.secondary_d })
hi("Include",      { fg = c.secondary_d })
hi("Define",       { fg = c.secondary_d })
hi("Macro",        { fg = c.secondary_d })
hi("PreCondit",    { fg = c.secondary_d })
hi("Type",         { fg = c.secondary })
hi("StorageClass", { fg = c.secondary })
hi("Structure",    { fg = c.secondary })
hi("Typedef",      { fg = c.secondary })
hi("Special",      { fg = c.tertiary_c })
hi("SpecialChar",  { fg = c.tertiary_c })
hi("Tag",          { fg = c.tertiary_c })
hi("Delimiter",    { fg = c.fg_dim })
hi("SpecialComment", { fg = c.fg_dim, italic = true })
hi("Debug",        { fg = c.error })
hi("Underlined",   { fg = c.primary, underline = true })
hi("Bold",         { bold = true })
hi("Italic",       { italic = true })
hi("Ignore",       { fg = c.outline })

-- Diagnostics
hi("Error",        { fg = c.error })
hi("ErrorText",    { fg = c.error, bg = c.bg_high })
hi("DiagnosticError",         { fg = c.error })
hi("DiagnosticWarn",          { fg = c.secondary })
hi("DiagnosticInfo",          { fg = c.primary })
hi("DiagnosticHint",          { fg = c.tertiary })
hi("DiagnosticUnderlineError", { sp = c.error,    underline = true })
hi("DiagnosticUnderlineWarn",  { sp = c.secondary, underline = true })
hi("DiagnosticUnderlineInfo",  { sp = c.primary,  underline = true })
hi("DiagnosticUnderlineHint",  { sp = c.tertiary, underline = true })
hi("DiagnosticVirtualTextError", { fg = c.error,    bg = c.bg_float })
hi("DiagnosticVirtualTextWarn",  { fg = c.secondary, bg = c.bg_float })
hi("DiagnosticVirtualTextInfo",  { fg = c.primary,  bg = c.bg_float })
hi("DiagnosticVirtualTextHint",  { fg = c.tertiary, bg = c.bg_float })
hi("DiagnosticFloatingError", { fg = c.error })
hi("DiagnosticFloatingWarn",  { fg = c.secondary })
hi("DiagnosticFloatingInfo",  { fg = c.primary })
hi("DiagnosticFloatingHint",  { fg = c.tertiary })
hi("DiagnosticSignError",     { fg = c.error })
hi("DiagnosticSignWarn",      { fg = c.secondary })
hi("DiagnosticSignInfo",      { fg = c.primary })
hi("DiagnosticSignHint",      { fg = c.tertiary })

-- LSP / semantic
hi("LspReferenceText",  { bg = c.bg_high })
hi("LspReferenceRead",  { bg = c.bg_high })
hi("LspReferenceWrite", { bg = c.bg_high })
hi("LspInlayHint",      { fg = c.fg_dim, bg = c.bg_float, italic = true })

-- Git
hi("DiffAdd",      { fg = c.tertiary_d, bg = c.bg_float })
hi("DiffChange",   { fg = c.secondary_d, bg = c.bg_float })
hi("DiffDelete",   { fg = c.error, bg = c.bg_float })
hi("DiffText",     { fg = c.on_pcont, bg = c.pcontainer })
hi("Added",        { fg = c.tertiary_d })
hi("Changed",      { fg = c.secondary_d })
hi("Removed",      { fg = c.error })
hi("GitSignsAdd",    { fg = c.tertiary_d })
hi("GitSignsChange", { fg = c.secondary_d })
hi("GitSignsDelete", { fg = c.error })

-- Spelling
hi("SpellBad",   { sp = c.error,     underline = true })
hi("SpellCap",   { sp = c.primary,   underline = true })
hi("SpellRare",  { sp = c.tertiary,  underline = true })
hi("SpellLocal", { sp = c.secondary, underline = true })

-- Plugins
hi("TelescopeNormal",      { fg = c.fg, bg = c.bg_float })
hi("TelescopeBorder",      { fg = c.outline, bg = c.bg_float })
hi("TelescopeTitle",       { fg = c.on_pcont, bg = c.pcontainer, bold = true })
hi("TelescopeSelection",   { fg = c.on_pcont, bg = c.pcontainer })
hi("TelescopeSelectionCaret", { fg = c.primary })
hi("TelescopeMatching",    { fg = c.tertiary, bold = true })
hi("TelescopePromptPrefix", { fg = c.primary })
hi("NeoTreeNormal",        { fg = c.fg, bg = c.bg })
hi("NeoTreeNormalNC",      { fg = c.fg_dim, bg = c.bg })
hi("NeoTreeWinSeparator",  { fg = c.divider })
hi("NeoTreeEndOfBuffer",   { fg = c.bg })
hi("NeoTreeRootName",      { fg = c.primary, bold = true })
hi("NeoTreeDirectoryName", { fg = c.secondary })
hi("NeoTreeDirectoryIcon", { fg = c.secondary })
hi("NeoTreeFileName",      { fg = c.fg })
hi("NeoTreeFileIcon",      { fg = c.tertiary })
hi("NeoTreeGitModified",   { fg = c.secondary_d })
hi("NeoTreeGitAdded",      { fg = c.tertiary_d })
hi("NeoTreeGitDeleted",    { fg = c.error })
hi("NeoTreeGitUntracked",  { fg = c.outline })
hi("NeoTreeIndentMarker",  { fg = c.outline })
hi("NeoTreeDimText",       { fg = c.outline })
hi("NormalSB",             { fg = c.fg, bg = c.bg }) -- generic sidebar (neo-tree fallback)

vim.g.colors_name = "matugen"
