local osc52 = require("vim.ui.clipboard.osc52")

local function paste_from_unnamed()
  return vim.split(vim.fn.getreg('"'), "\n")
end

-- The terminal has to carry the clipboard here. wl-copy needs wlr-data-control
-- or ext-data-control and Mutter implements neither, and over ssh there is no
-- local clipboard tool at all, so OSC 52 is the only path that works on every
-- host. Neovim would not pick it on its own because 'clipboard' is set (see
-- autoload/provider/clipboard.vim), hence the explicit provider.
-- Reads stay local: herdr never answers an OSC 52 query, and the built-in
-- reader blocks for ten seconds waiting for a reply that never arrives.
vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = paste_from_unnamed,
    ["*"] = paste_from_unnamed,
  },
}
