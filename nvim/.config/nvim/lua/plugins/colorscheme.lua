return {
  "bluz71/vim-nightfly-colors",
  name = "nightfly",
  priority = 1000,
  config = function()
    vim.cmd("colorscheme nightfly")

    -- make background transparent
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

    vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNrAbove", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNrBelow", { bg = "none" })

    -- custom highlights
    vim.api.nvim_set_hl(0, "neon", { fg = "#39FF14" })
    vim.api.nvim_set_hl(0, "brightred", { fg = "#FF3131" })
  end,
}
