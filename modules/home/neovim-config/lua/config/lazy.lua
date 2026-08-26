local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "nvim-lua/plenary.nvim", lazy = true },

    { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
    { "folke/todo-comments.nvim", opts = {} },

    { import = "plugins.bufferline" },
    { import = "plugins.copilot" },
    { import = "plugins.dracula" },
    { import = "plugins.git-blame" },
    { import = "plugins.gitsigns" },
    { import = "plugins.lualine" },
    { import = "plugins.markdown" },
    { import = "plugins.noice" },
    { import = "plugins.conform" },
    { import = "plugins.fzf-lua" },
    { import = "plugins.nvim-cmp" },
    { import = "plugins.nvim-treesitter" },
    { import = "plugins.nvim-ufo" },
    { import = "plugins.oil" },
    { import = "plugins.hop" },
    { import = "plugins.toggleterm" },
    { import = "plugins.vimdoc-ja" },
    { import = "plugins.lsp" },
  },
  checker = { enabled = true },
  lockfile = vim.fn.stdpath("data") .. "/lazy/lazy-lock.json",
})
