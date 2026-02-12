-- ~/.config/nvim/lua/plugins/lsp.lua

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Setup mason
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "gopls",       -- Go LSP
          "terraformls",
          "tflint",
          "marksman",    -- Markdown LSP
          "yamlls",      -- YAML LSP
        },
      })

      -- LSP keybindings are now managed centrally in lua/config/keymaps.lua
      -- This autocmd is kept for future buffer-local LSP configurations if needed
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          -- Buffer-local LSP setup can go here if needed
          -- Most keymaps are now in lua/config/keymaps.lua
        end,
      })

      -- Configure Lua LSP using new vim.lsp.config API
      vim.lsp.config('lua_ls', {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      })

      -- Configure Terraform LSP
      vim.lsp.config('terraformls', {
        cmd = { 'terraform-ls', 'serve' },
        filetypes = { 'terraform', 'terraform-vars' },
        root_markers = { '.terraform', '.git' },
        capabilities = capabilities,
      })

      -- Configure Markdown LSP
      vim.lsp.config('marksman', {
        cmd = { 'marksman', 'server' },
        filetypes = { 'markdown', 'markdown.mdx' },
        root_markers = { '.git', '.marksman.toml' },
        capabilities = capabilities,
      })

      -- Configure YAML LSP
      vim.lsp.config('yamlls', {
        cmd = { 'yaml-language-server', '--stdio' },
        filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
        root_markers = { '.git' },
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = {
              kubernetes = "*.yaml",
              ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
              ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
              ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
              ["http://json.schemastore.org/prettierrc"] = ".prettierrc.{yml,yaml}",
              ["http://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
              ["http://json.schemastore.org/ansible-playbook"] = "*play*.{yml,yaml}",
              ["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
              ["https://json.schemastore.org/dependabot-v2"] = ".github/dependabot.{yml,yaml}",
              ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{yml,yaml}",
              ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] = "*api*.{yml,yaml}",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
              ["https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json"] = "*flow*.{yml,yaml}",
            },
            format = { enable = true },
            validate = true,
            completion = true,
          }
        }
      })

      -- Configure Go LSP
      vim.lsp.config('gopls', {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = { 'go.work', 'go.mod', '.git' },
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
              fieldalignment = true,
              nilness = true,
            },
            staticcheck = true,
            gofumpt = true,
            usePlaceholders = true,
            completeUnimported = true,
            ["local"] = "github.com/bigid/bigid-operator",
            directoryFilters = { "-.git", "-vendor", "-testbin", "-bin" },
          },
        },
      })

      -- Enable LSP servers
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('gopls')
      vim.lsp.enable('terraformls')
      vim.lsp.enable('marksman')
      vim.lsp.enable('yamlls')
    end,
  },
}
