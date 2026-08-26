return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      views = {
        popup = {
          win_options = {
            winblend = 0,
          },
        },
        notify = {
          win_options = {
            winblend = 0,
          },
        },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
    },
  },
}
