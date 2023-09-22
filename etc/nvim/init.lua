
vim.cmd[[colorscheme dracula]]

vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }

vim.g.mapleader = " ";

local noremap = function(mode, lhs, rhs)
  vim.api.nvim_set_keymap(mode, lhs, rhs, { noremap = true, silent = true })
end

local nnoremap = function(lhs, rhs)
  noremap('n', lhs, rhs)
end

nnoremap("<Leader><Leader>", ":Files<cr>")
nnoremap("<Leader>b", ":Buffers<cr>")
