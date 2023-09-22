vim.cmd [[colorscheme dracula]]

vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.opt.clipboard:append { 'unnamed', 'unnamedplus' }

vim.g.mapleader = " ";

local noremap = function(mode, lhs, rhs, opts)
  vim.keymap.set(
    mode,
    lhs,
    rhs,
    vim.tbl_deep_extend("force", { noremap = true, silent = true }, opts or {})
  )
end

local nnoremap = function(lhs, rhs, opts)
  noremap('n', lhs, rhs, opts)
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "nix",
  callback = function()
    vim.opt_local.commentstring = "# %s"
  end
});

nnoremap("<Leader><Leader>", ":Files<cr>")
nnoremap("<Leader>b", ":Buffers<cr>")

local lspconfig = require('lspconfig')

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          'vim',
          'require'
        },
      },
      workLeader = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

lspconfig.nil_ls.setup {}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
nnoremap('<Leader>e', vim.diagnostic.open_float)
nnoremap('[d', vim.diagnostic.goto_prev)
nnoremap(']d', vim.diagnostic.goto_next)
nnoremap('<Leader>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    nnoremap('gD', vim.lsp.buf.declaration, opts)
    nnoremap('gd', vim.lsp.buf.definition, opts)
    nnoremap('K', vim.lsp.buf.hover, opts)
    nnoremap('gi', vim.lsp.buf.implementation, opts)
    nnoremap('<C-k>', vim.lsp.buf.signature_help, opts)
    nnoremap('<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    nnoremap('<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    nnoremap('<Leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workLeader_folders()))
    end, opts)
    nnoremap('<Leader>D', vim.lsp.buf.type_definition, opts)
    nnoremap('<Leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
    nnoremap('gr', vim.lsp.buf.references, opts)
    nnoremap('<Leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
