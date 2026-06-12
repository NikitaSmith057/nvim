-- ----------------------------------------------------------------
-- Plugins
-- ----------------------------------------------------------------

vim.cmd([[
call plug#begin(stdpath('config') . '/plugged')
  Plug 'junegunn/vim-easy-align'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'derekwyatt/vim-fswitch'
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'lukas-reineke/indent-blankline.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'tpope/vim-fugitive'
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'RRethy/vim-illuminate'
call plug#end()
]])

-- ----------------------------------------------------------------
-- Settings
-- ----------------------------------------------------------------

-- tell terminal to use nvim colorscheme
vim.opt.termguicolors = true

vim.cmd("colorscheme dosbox-black")
vim.opt.background = "dark"

-- disable all bells (replaces: set visualbell t_vb=)
vim.opt.belloff = "all"

-- enable backspace in INSERT
vim.opt.backspace = { "indent", "eol", "start" }

-- disable "SEARCH HIT BOTTOM..." messages
vim.opt.shortmess:append("s")

vim.opt.wildmode = "list:full"

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

vim.api.nvim_create_user_command("GenerateTags", "!ctags -f tags --exclude=\"*metagen_base*\" --exclude=\"*metagen_os*\" -R src", {})

-- ----------------------------------------------------------------
-- Build
-- ----------------------------------------------------------------

if vim.fn.has("win32") == 1 then
  vim.opt.makeprg = "cmd /c build.bat"
  vim.opt.errorformat = {
    "%f(%l\\,%c): fatal error %m",
    "%f(%l\\,%c): %trror %m",
    "%f(%l\\,%c): %tarning %m",
    "%f(%l): fatal error %m",
    "%f(%l): %trror %m",
    "%f(%l): %tarning %m",
    "%f(%l): %m",
  }
else
  vim.opt.makeprg = "./build.sh"
  vim.opt.errorformat = {
    "%E%f:%l:%c: fatal error: %m",
    "%E%f:%l:%c: error: %m",
    "%W%f:%l:%c: warning: %m",
    "%I%f:%l:%c: note: %m",
    "%E%f:%l: fatal error: %m",
    "%E%f:%l: error: %m",
    "%W%f:%l: warning: %m",
    "%I%f:%l: note: %m",
    "%f:%l:%c: %m",
    "%f:%l: %m",
  }
end

vim.api.nvim_create_user_command("MakeQuickFix", function(opts)
  vim.cmd("silent! make " .. opts.args)
  vim.cmd("botright copen")
end, { nargs = "*" })

vim.api.nvim_create_user_command("MakeQuickFixStay", function(opts)
  local win = vim.fn.win_getid()
  local pos = vim.fn.getpos(".")
  vim.cmd("MakeQuickFix " .. opts.args)
  vim.fn.win_gotoid(win)
  vim.fn.setpos(".", pos)
end, { nargs = "*" })

-- open quickfix at the bottom after build
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern  = "make",
  command  = "botright copen",
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
vim.keymap.set("n", "<F5>", function()
  vim.cmd("MakeQuickFixStay no_meta raddbg")
  if vim.v.shell_error == 0 then
    vim.cmd("MakeQuickFixStay no_meta asan torture")
  end
end)
vim.keymap.set("n", "<F7>", ":cn<CR>")

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
vim.keymap.set("x", "\\a", ":EasyAlign /\\s\\+\\%(\\*\\s*\\)*\\ze\\h\\w*\\s*\\%((\\|;\\)/r0<CR>")
vim.keymap.set("x", "\\s", ":EasyAlign /(/r0<CR>")

vim.keymap.set("n", "<A-1>",     ":b#<CR>")
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<CR>")
vim.keymap.set("n", "<leader>e", ":e ")
vim.keymap.set("n", "<leader>m", ":silent make! asan no_meta ")
vim.keymap.set("n", "<leader>t", ":tselect ")
vim.keymap.set("n", "<leader>c", ":MakeQuickFixStay no_meta raddbg<CR>")
vim.keymap.set("n", "\\w", "mzggVG\"+y`z")

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
custom_powerline.normal.b.fg = '#eeeeee'
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

local function line_col_location()
  local line = vim.fn.line('.')
  local col = vim.fn.virtcol('.')
  return string.format("Line: %d Col: %d", line, col)
end

require('lualine').setup({
  options = {
    theme = custom_powerline,
    icons_enabled = false,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    tabline = {}
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      {
        gs_branch,
        color = { fg = '#dddddd' },
      },
    },
    lualine_c = {
      {
        'filename',
        path = 1,
        shorting_target = 0,
      },
    },

    lualine_x = {
      {
        line_col_location,
        color = function() return { fg = '#eeeeee', bg = '#2a2a2a', gui = '' } end,
      },
      {
        'fileformat',
        fmt = string.upper,
        color = function() return { fg = '#eeeeee', bg = '#353535', gui = '' } end,
      },
      {
        'o:encoding', -- option component same as &encoding in viml
        fmt = string.upper, -- I'm not sure why it's upper case either ;)
        -- cond = conditions.hide_in_width,
        color = function() return { fg = '#eeeeee', bg = '#353535', gui = '' } end,
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

-- ----------------------------------------------------------------
-- Git Signs
-- ----------------------------------------------------------------

vim.api.nvim_set_hl(0, 'GitSignsChange',  { fg = '#ffff00' })
vim.api.nvim_set_hl(0, 'GitSignsAdd',     { fg = '#00ff00' })
vim.api.nvim_set_hl(0, 'GitSignsDelete',  { fg = '#ff0000' })

-- ----------------------------------------------------------------
-- ripgrep
-- ----------------------------------------------------------------

-- winget install BurntSushi.ripgrep.MSVC

vim.o.grepprg = "rg --vimgrep --smart-case"
vim.o.grepformat = "%f:%l:%c:%m"

local function prompt_substitute()
  local pattern = vim.fn.input("grep: ")
  if pattern == nil or pattern == "" then
    return nil
  end

  local replacement = vim.fn.input("replace: ")
  if replacement == nil then
    return nil
  end

  local escaped_pattern = "\\C" .. vim.fn.escape(pattern, "/\\")
  local escaped_replacement = vim.fn.escape(replacement, "/\\&")
  return pattern, escaped_pattern, escaped_replacement
end

vim.keymap.set("n", "\\g", function()
  local pattern = vim.fn.input("grep: ")
  if pattern == nil or pattern == "" then
    return
  end
  vim.cmd("silent grep! " .. vim.fn.shellescape(pattern))
  vim.cmd("cwindow")
end)

vim.keymap.set("n", "\\r", function()
  local pattern, escaped_pattern, escaped_replacement = prompt_substitute()
  if pattern == nil then
    return
  end

  vim.cmd("silent grep! " .. vim.fn.shellescape(pattern))
  vim.cmd("silent cfdo %s/" .. escaped_pattern .. "/" .. escaped_replacement .. "/g | update")
  vim.cmd("cwindow")
end)
