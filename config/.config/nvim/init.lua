require("config.lazy")

vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

vim.keymap.set("n", "<Space><Space>x", "<Cmd>source %<CR>")
vim.keymap.set("n", "<Space>x", ":.lua<CR>")
vim.keymap.set("v", "<Space>x", ":lua<CR>")
