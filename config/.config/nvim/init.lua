require("config.lazy")

vim.opt.shiftwidth = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

vim.keymap.set("n", "<Space><Space>x", "<Cmd>source %<CR>")
vim.keymap.set("n", "<Space>x", ":.lua<CR>")
vim.keymap.set("v", "<Space>x", ":lua<CR>")

vim.keymap.set("n", "<M-j>", "<Cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<Cmd>cprev<CR>")

vim.keymap.set("n", "-", "<Cmd>Oil<CR>")

vim.keymap.set("n", "<Space>st", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 15)
end)
