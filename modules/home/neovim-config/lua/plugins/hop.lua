return {
  "smoka7/hop.nvim",
  version = "*",
  config = function()
    local hop = require("hop")
    hop.setup({})
    vim.keymap.set("n", "<Leader><Leader>", "<cmd>HopWord<CR>", { noremap = true, silent = true })
  end,
}
