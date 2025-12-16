return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- 1. Mason
            require("mason").setup()

            -- 2. Mason LSP bridge
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    -- add more servers here
                    -- "tsserver",
                    -- "pyright",
                },
                automatic_installation = true,
            })

            -- 3. LSP defaults
            local lspconfig = require("lspconfig")

            -- Optional: common capabilities (for nvim-cmp later)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- 4. Keymaps (buffer-local)
            local on_attach = function(_, bufnr)
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end

                map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
                map("n", "gr", vim.lsp.buf.references, "References")
                map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
                map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
                map("n", "K", vim.lsp.buf.hover, "Hover")
                map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
                map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

                if vim.lsp.inlay_hint then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end

            -- 5. Setup servers
            -- Mason ↔ LSP bridge (NEW API)
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                },

                handlers = {
                    -- default handler
                    function(server_name)
                        lspconfig[server_name].setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                        })
                    end,

                    -- lua specific
                    lua_ls = function()
                        lspconfig.lua_ls.setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    diagnostics = { globals = { "vim" } },
                                    workspace = { checkThirdParty = false },
                                },
                            },
                        })
                    end,
                },
            })

            -- 6. Diagnostics UI
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })
        end,
    },
}

