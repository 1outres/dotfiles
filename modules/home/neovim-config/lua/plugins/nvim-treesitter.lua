return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    config = function(plugin)
      -- Parsers come from Nix, so :TSInstall never runs and never links the
      -- bundled queries into install_dir the way upstream expects. Neovim only
      -- ships highlights for a few languages, so add the plugin's own queries.
      vim.opt.runtimepath:prepend(plugin.dir .. "/runtime")

      require("nvim-treesitter").setup()

      local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          if vim.bo[args.buf].buftype ~= "" then
            return
          end

          local ft = vim.bo[args.buf].filetype
          if ft == "" then
            return
          end

          local ok_lang, lang = pcall(vim.treesitter.language.get_lang, ft)
          if not ok_lang or not lang or lang == "" then
            return
          end

          -- Queries ship for every language the plugin knows, but Nix supplies
          -- only a subset of the parsers, so probe the parser itself.
          if not pcall(vim.treesitter.language.add, lang) then
            return
          end

          local ok_highlights, highlights = pcall(vim.treesitter.query.get, lang, "highlights")
          if ok_highlights and highlights then
            pcall(vim.treesitter.start, args.buf, lang)
          end

          local ok_indents, indents = pcall(vim.treesitter.query.get, lang, "indents")
          if ok_indents and indents then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufNewFile", "BufRead" },
    opts = {},
  },
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {},
  },
}
