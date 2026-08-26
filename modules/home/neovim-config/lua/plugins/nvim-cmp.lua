return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-omni",
      "hrsh7th/cmp-nvim-lua",
      "zbirenbaum/copilot-cmp",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-calc",
      "ray-x/cmp-treesitter",
      "folke/lazydev.nvim",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")
      local types = require("cmp.types")
      local lspkind = require("lspkind")

      vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
      local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
          return false
        end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
      end

      cmp.setup({
        sources = {
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lsp_document_symbol" },
          { name = "buffer" },
          { name = "path" },
          { name = "lazydev", group_index = 0 },
          {
            name = "omni",
            option = {
              disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" },
            },
          },
          { name = "nvim_lua" },
          { name = "emoji" },
          { name = "calc" },
          { name = "treesitter" },
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol",
            maxwidth = {
              menu = 50,
              abbr = 50,
            },
            ellipsis_char = "...",
            show_labelDetails = true,
            symbol_map = { Copilot = "" },
            before = function(entry, vim_item)
              return vim_item
            end,
          }),
        },
        mapping = {
          ["<Down>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end),
          ["<Up>"] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline({
          ["<CR>"] = {
            c = function(default)
              if cmp.get_selected_entry() then
                return cmp.confirm({ select = true })
              end

              default()
            end,
          },
          ["<Esc>"] = {
            c = function(default)
              if cmp.get_selected_entry() then
                return cmp.abort()
              end
              default()
            end,
          },
        }),
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
        },
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          ["<CR>"] = {
            c = function(default)
              if cmp.get_selected_entry() then
                return cmp.confirm({ select = true })
              end

              default()
            end,
          },
          ["<Esc>"] = {
            c = function(default)
              if cmp.get_selected_entry() then
                return cmp.abort()
              end
              default()
            end,
          },
        }),
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
        },
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }),
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
