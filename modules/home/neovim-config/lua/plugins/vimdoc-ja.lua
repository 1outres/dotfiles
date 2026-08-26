return {
  "vim-jp/vimdoc-ja",
  event = "VeryLazy",
  init = function()
    vim.opt.helplang = "ja,en"
  end,
}
