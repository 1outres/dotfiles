return {
  {
    "ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").setup({})

      vim.keymap.set("n", "<Leader>ff", "<cmd>FzfLua files<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>fg", "<cmd>FzfLua live_grep<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>fb", "<cmd>FzfLua buffers<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<Leader>fa", "<cmd>FzfLua lsp_document_symbols<CR>", { noremap = true, silent = true })
    end,
  },
}
