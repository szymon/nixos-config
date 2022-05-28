local util = require "lspconfig/util"
local nvim_lsp = require("lspconfig")
USER = vim.fn.expand("$USER")

local sumneko_root_path = ""
local sumneko_binary = ""

-- cmp setup -{{{
local cmp = require("cmp")
local cmp_options_insert = { behavior = require 'cmp.types'.cmp.SelectBehavior.Insert }
local cmp_options_select = { behavior = require 'cmp.types'.cmp.SelectBehavior.Select }

cmp.setup({
    preselect = cmp.PreselectMode.None,
    mapping = {
        ["<c-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c', 's' }),
        ["<c-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c', 's' }),
        ["<c-space>"] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c', 's' }),
        ["<c-y>"] = cmp.config.disable,
        ["<c-e>"] = { i = cmp.mapping.abort(), c = cmp.mapping.close() },
        --        ["<cr>"] = cmp.mapping.confirm({select = true})
        ["<c-n>"] = cmp.mapping(cmp.mapping.select_next_item(cmp_options_insert), { "i", "c", "s" }),
        ["<c-p>"] = cmp.mapping(cmp.mapping.select_prev_item(cmp_options_insert), { "i", "c", "s" }),
        ["<tab>"] = cmp.mapping(cmp.mapping.select_next_item(cmp_options_insert), { "i", "c", "s" }),
        ["<s-tab>"] = cmp.mapping(cmp.mapping.select_prev_item(cmp_options_insert), { "i", "c", "s" })
    },
    sources = cmp.config.sources({ { name = "nvim_lsp" } }, { { name = "buffer" } })
})
cmp.setup.filetype("gitcommit", { sources = cmp.config.sources({ { name = "cmp_git" } }, { { name = "buffer" } }) })

-- local custom_handlers = {
--    ["textDocument/definition"] = function(_, result, params)
--        if result == nil or vim.tbl_isempty(result) then
--            local _ = vim.lsp.log.info() and vim.lsp.log.info(params.method, "No location found")
--            return nil
--        end
--
--        if vim.tbl_islist(result) then
--            vim.lsp.util.jump_to_location(result[1])
--            vim.fn.setqflist(vim.lsp.util.locations_to_items(result))
--        else
--            vim.lsp.util.jump_to_location(result)
--        end
--
--    end
-- }

cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })

local mapping = cmp.mapping.preset.cmdline()
mapping["<c-n>"] = nil
mapping["<c-p>"] = nil

cmp.setup.cmdline(":", { sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }) })

-- -}}}

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- local capabilities = {}

---@param method string
local function select_client(method)
    local clients = vim.tbl_values(vim.lsp.buf_get_clients())
    clients = vim.tbl_filter(function(client)
        return client.supports_method(method)
    end, clients)

    for i = 1, #clients do if clients[i].name == "efm" then return clients[i] end end
    return clients[1]
end

function Formatting(options, timeout_ms)
    ---@diagnostic disable-next-line: redefined-local
    local util = vim.lsp.util
    local params = util.make_formatting_params(options)
    local bufnr = vim.api.nvim_get_current_buf()
    local client = select_client("textDocument/formatting")
    if client == nil then return end

    local result, err = client.request_sync("textDocument/formatting", params, timeout_ms, bufnr)
    if result and result.result then
        util.apply_text_edits(result.result, bufnr, client.offset_encoding)
    elseif err then
        vim.notify("vim.lsp.buf.formatting_sync" .. err, vim.log.levels.WARN)
    end

end

---@diagnostic disable-next-line: unused-local
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    -- local function buf_set_option(...)
    --     vim.api.nvim_buf_set_option(bufnr, ...)
    -- end

    -- Enable completion triggered by <c-x><c-o>
    -- buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap = true, silent = true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

    buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    -- buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_quickfixlist()<CR>', opts)
    buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

    -- require'illuminate'.on_attach(client)

    vim.cmd [[
    augroup My_group
        au!
        " autocmd BufWritePre * lua Formatting()
        autocmd BufWritePre *.go lua Formatting()
        autocmd BufWritePre *.lua lua vim.lsp.buf.formatting()
        autocmd BufWritePre *.py lua vim.lsp.buf.formatting()
        autocmd BufWritePre *.ts lua Formatting()
        autocmd BufWritePre *.nix lua Formatting()
        autocmd FileType yaml setlocal ts=12 sts=2 sw=2 expandtab indentkeys-=<:>
        autocmd FileType go setlocal noexpandtab ts=4 sts=4 sw=4
        autocmd FileType typescript setlocal noexpandtab ts=2 sts=2 sw=2
        autocmd FileType html setlocal noexpandtab ts=2 sts=2 sw=2
    augroup END
    ]]

end

nvim_lsp.pyright.setup {
    -- handlers = custom_handlers,
    on_attach = on_attach,
    -- capabilities = capabilities,
    flags = { debounce_text_changes = 150 },
    settings = {
        python = { analysis = { autoSearchPaths = true, diagnosticMode = "workspace", useLibraryCodeForTypes = true } }
    }
}
nvim_lsp.tsserver.setup { capabilities = capabilities, on_attach = on_attach, flags = { debounce_text_changes = 150 } }

nvim_lsp.ccls.setup { on_attach = on_attach, capabilities = capabilities, flags = { debounce_text_changes = 150 } }

nvim_lsp.hls.setup { on_attach = on_attach, settings = { haskell = { hlintOn = true, formattingProvider = "fourmolu" } } }

nvim_lsp.sumneko_lua.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "lua-language-server" },
    settings = {
        Lua = {
            runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
            diagnostics = { globals = { "vim" } },
            workspace = {
                library = {
                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                    [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
                    -- [vim.fn.expand(vim.fn.stdpath('data') .. "")] = true
                }
            }
        }
    }
}
local languages = {
    -- lua = {
    --     {
    --         formatCommand = "lua-format -i --no-keep-simple-function-one-line --no-break-after-operator --column-limit=120 --break-after-table-lb",
    --         formatStdin = true
    --     }
    -- },
    python = {
        { formatCommand = "black --quiet -", formatStdin = true },
        { formatCommand = "isort --profile=black -", formatStdin = true },
        { formatCommand = "autoflake -", formatStdin = true }
    },
    typescript = { { formatCommand = "prettier", formatStdin = true } },
    nix = { { formatCommand = "nixpkgs-fmt", formatStdin = true } }
}

-- luarocks install --server=https://luarocks.org/dev luaformatter
-- go install github.com/mattn/efm-langserver
nvim_lsp.efm.setup {
    init_options = { documentFormatting = true },
    filetypes = vim.tbl_keys(languages),
    settings = {
        rootMarkers = {
            ".git/", ".project", "venv/", ".venv/", vim.fn.expand("~/.config/nvim"), vim.fn.expand("~/.config/nvim/lua")
        },
        languages = languages
    }
}

nvim_lsp.yamlls.setup {
    capabilities = capabilities,
    settings = {
        yamlls = {
            schemas = {
                ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "~/code/argonaut",
                ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.16.0-standalone-strict/all.json"] = ".*\\.k8s\\.yaml"
            },
            schemaDownload = { enable = true },
            validate = true
        }
    }
}

nvim_lsp.gopls.setup {
    cmd = { "gopls", "serve" },
    on_attach = on_attach,
    filetypes = { "go", "gomod" },
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    settings = { gopls = { analyses = { unusedparams = true, shadow = true }, staticcheck = true } }
}

nvim_lsp.rnix.setup {
    cmd = { "rnix-lsp" },
    on_attach = on_attach,
    filetypes = { "nix" },
    root_dir = util.root_pattern("flake.nix", "home-manager.nix", ".git"),
}

function GoOrdImports(wait_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end

function GoOnPreWrite()
    vim.lsp.buf.formatting_sync()
    -- GoOrdImports(1000)
end

require("lsp_signature").setup { bind = true, handler_opts = { border = "shadow" } }

-- vim: foldmethod=marker foldmarker=-{{{,-}}}:
