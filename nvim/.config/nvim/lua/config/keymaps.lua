-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map jk to escape in insert mode
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })

-- Disable Esc key in insert mode
vim.keymap.set("i", "<Esc>", "<Nop>", { noremap = true, silent = true })
