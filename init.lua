-- ----------------------------------------------------------------
-- Plugins
-- ----------------------------------------------------------------

vim.cmd([[
call plug#begin('~/AppData/Local/nvim/plugged')
  Plug 'junegunn/vim-easy-align'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install' }
  Plug 'junegunn/fzf.vim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'derekwyatt/vim-fswitch'
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'lukas-reineke/indent-blankline.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'tpope/vim-fugitive'
call plug#end()
]])

-- ----------------------------------------------------------------
-- Settings
-- ----------------------------------------------------------------

vim.cmd("colorscheme dosbox-black")
vim.opt.background = "dark"

-- disable all bells (replaces: set visualbell t_vb=)
vim.opt.belloff = "all"

-- enable backspace in INSERT
vim.opt.backspace = { "indent", "eol", "start" }

-- disable "SEARCH HIT BOTTOM..." messages
vim.opt.shortmess:append("s")

vim.opt.wildmode = "list:full"

-- clang and cl error parser
vim.opt.errorformat = "%f(%l): %m"

-- auto-align new-line function arguments
vim.opt.smartindent = true
vim.opt.cindent     = true
vim.opt.cinoptions:append("(0")
vim.opt.cinoptions:append("l1")
vim.opt.cinoptions:append(":0")
vim.opt.cinoptions:append("L")
vim.opt.softtabstop = 2
vim.opt.shiftwidth  = 2
vim.opt.expandtab   = true
vim.opt.tabstop     = 2
vim.opt.textwidth   = 0
vim.opt.wrapmargin  = 0

-- ctags search path
vim.opt.tags = "./.ctags,tags;$HOME"

vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.wrap           = false
vim.opt.colorcolumn    = "120"
vim.opt.cursorline     = true

-- swap/backup files
vim.opt.directory  = "c:/vim_swapfiles"
vim.opt.backupdir  = "c:/vim_swapfiles"
vim.opt.backup     = false
vim.opt.undofile   = false

-- search
vim.opt.ignorecase = true
vim.opt.incsearch  = true

vim.opt.clipboard = { "unnamed", "unnamedplus" }

-- ----------------------------------------------------------------
-- Highlight
-- ----------------------------------------------------------------

vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#1e1e1e" })
vim.api.nvim_set_hl(0, "Pmenu", { ctermbg = 234, ctermfg = 255, bg = "#1e1e1e", fg = "#dcdcdc" })
vim.cmd("highlight! clear MatchParen")

-- enable hlsearch while typing, disable when done
local search_hl = vim.api.nvim_create_augroup("SearchHighlight", { clear = true })
vim.api.nvim_create_autocmd("CmdlineEnter", {
  group    = search_hl,
  pattern  = { "/", "?" },
  callback = function() vim.opt.hlsearch = true end,
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group    = search_hl,
  pattern  = { "/", "?" },
  callback = function() vim.opt.hlsearch = false end,
})

-- ----------------------------------------------------------------
-- ctags
-- ----------------------------------------------------------------

vim.api.nvim_create_user_command("GenerateTags", "!ctags -R src", {})

-- ----------------------------------------------------------------
-- Build
-- ----------------------------------------------------------------

vim.opt.makeprg = "cmd /c build.bat"

vim.api.nvim_create_user_command("MakeQuickFix", function(opts)
  vim.cmd("silent! make " .. opts.args)
  vim.cmd("botright copen")
end, { nargs = "*" })

vim.api.nvim_create_user_command("MakeQuickFixStay", function()
  local win = vim.fn.win_getid()
  local pos = vim.fn.getpos(".")
  vim.cmd("MakeQuickFix san radlink")
  vim.fn.win_gotoid(win)
  vim.fn.setpos(".", pos)
end, {})

-- open quickfix at the bottom after build
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern  = "make",
  command  = "copen",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern  = "qf",
  command  = "wincmd J",
})

-- ----------------------------------------------------------------
-- Key Maps
-- ----------------------------------------------------------------

vim.keymap.set("v", "<C-c>", '"+y')

vim.keymap.set("n", "<F1>", ":GenerateTags<CR>")
vim.keymap.set("n", "<F2>", ":ccl<CR>")
vim.keymap.set("n", "<F4>", ":e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>")
vim.keymap.set("n", "<F5>", ":MakeQuickFixStay<CR>")
vim.keymap.set("n", "<F7>", ":cn<CR>")

vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")

-- fswitch: toggle between .c/.cpp and .h
vim.keymap.set("n", "<Leader>ol", "<cmd>FSRight<CR>",      { silent = true })
vim.keymap.set("n", "<Leader>oL", "<cmd>FSSplitRight<CR>", { silent = true })
vim.keymap.set("n", "<Leader>of", "<cmd>FSHere<CR>",       { silent = true })
vim.keymap.set("n", "<Leader>oh", "<cmd>FSLeft<CR>",       { silent = true })
vim.keymap.set("n", "<Leader>oH", "<cmd>FSSplitLeft<CR>",  { silent = true })

vim.keymap.set("n", "H", "<nop>")
vim.keymap.set("n", "L", "<nop>")

-- easy align
vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")

vim.keymap.set("n", "<A-1>",     ":b#<CR>")
vim.keymap.set("n", "<leader>b", ":b ")
vim.keymap.set("n", "<leader>e", ":e ")
vim.keymap.set("n", "<leader>m", ":silent make! san ")
vim.keymap.set("n", "<leader>t", ":ta ")
vim.keymap.set("n", "<leader>c", ":MakeQuickFixStay<CR>")

-- ----------------------------------------------------------------
-- gitsigns
-- ----------------------------------------------------------------

require("gitsigns").setup()

-- ----------------------------------------------------------------
-- LuaLine
-- ----------------------------------------------------------------

local custom_powerline = require'lualine.themes.powerline'

custom_powerline.normal.a.gui = ''
custom_powerline.normal.a.bg = '#cccccc'
custom_powerline.normal.a.fg = '#000000'

-- file time stamp
custom_powerline.normal.b.fg = '#ffffff'
custom_powerline.normal.b.bg = '#404040'
custom_powerline.normal.b.gui = ''

-- status line
custom_powerline.normal.c.fg = '#cccccc'
custom_powerline.normal.c.bg = '#1a1a1a'
custom_powerline.normal.c.gui = ''

custom_powerline.insert.a.gui = ''
custom_powerline.insert.a.bg = '#0AA1FF'
custom_powerline.insert.a.fg = '#ffffff'

custom_powerline.insert.c.fg = '#cccccc'
custom_powerline.insert.c.bg = '#1a1a1a'
custom_powerline.insert.c.gui = ''

custom_powerline.insert.b.fg = '#ffffff'
custom_powerline.insert.b.bg = '#404040'
custom_powerline.insert.b.gui = ''

custom_powerline.visual.a.gui = ''
custom_powerline.replace.a.gui = ''
custom_powerline.inactive.a.gui = ''

local function gs_branch()
  return vim.b.gitsigns_head or ""
end

require('lualine').setup({
  options = {
    theme = custom_powerline,
    icons_enabled = false,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { gs_branch },
    lualine_c = { 'filename' },

    lualine_x = {
      {
        'location',
        color = function() return { fg = '#ffffff', bg = '#2a2a2a', gui = '' } end,
      },
      {
        'fileformat',
        color = function() return { fg = '#ffffff', bg = '#353535', gui = '' } end,
      },
    },
    lualine_y = { function() return os.date("%H:%M:%S | %d/%m/%Y", vim.fn.getftime(vim.fn.expand("%:p"))) end, },
    lualine_z = {},
  },
})

-- ----------------------------------------------------------------
-- Indent Blankline
-- ----------------------------------------------------------------

local ibl_hooks = require("ibl.hooks")
ibl_hooks.register(ibl_hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "White", { fg = "#333333" })
end)

require("ibl").setup({
  indent = {
    char      = "▏",
    highlight = { "White" },
  },
})
