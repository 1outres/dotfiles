vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })

vim.keymap.set("n", "<Esc><Esc>", ":<C-u>nohlsearch<CR><Esc>", { noremap = true, silent = true })

vim.keymap.set("n", "x", '"_x', { noremap = true })

vim.keymap.set("n", "<C-n>", ":Oil<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { noremap = true, silent = true })
