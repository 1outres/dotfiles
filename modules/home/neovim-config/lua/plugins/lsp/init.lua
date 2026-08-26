return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      vim.keymap.set("n", "<Leader>]", vim.lsp.buf.definition, { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>i", "<cmd>FzfLua lsp_implementations<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>re", "<cmd>FzfLua lsp_references<CR>", { noremap = true, silent = true })

      vim.keymap.set("n", "<Leader>h", vim.lsp.buf.hover, { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>rr", vim.lsp.buf.rename, { noremap = true, silent = true })

      vim.keymap.set("n", "<Leader>m", "<cmd>FzfLua diagnostics_workspace<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>c", "<cmd>FzfLua diagnostics_document<CR>", { noremap = true, silent = true })

      vim.keymap.set("n", "<Leader>n", vim.diagnostic.goto_next, { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>N", vim.diagnostic.goto_prev, { noremap = true, silent = true })

      vim.keymap.set("n", "<M-CR>", "<cmd>FzfLua lsp_code_actions<CR>", { noremap = true, silent = true })

      vim.diagnostic.config({ virtual_text = true, severity_sort = true })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {},
  },
  {
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },
}
