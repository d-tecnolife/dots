return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    local mode_file = vim.fn.expand("~/.cache/.theme_mode")

    local function is_light()
      if vim.fn.filereadable(mode_file) == 1 then
        local line = vim.trim(vim.fn.readfile(mode_file)[1] or "")
        return line == "Light"
      end
      return false
    end

    local function get_scheme()
      return is_light() and "tokyonight-day" or "tokyonight-night"
    end

    local function apply_mode()
      local scheme = get_scheme()
      if vim.g.colors_name ~= scheme then
        vim.cmd("colorscheme " .. scheme)
      end
    end

    require("tokyonight").setup({
      transparent = true,
    })

    vim.cmd("colorscheme " .. get_scheme())

    -- custom highlights
    vim.api.nvim_set_hl(0, "neon", { fg = "#39FF14" })
    vim.api.nvim_set_hl(0, "brightred", { fg = "#FF3131" })

    vim.api.nvim_create_autocmd("FocusGained", {
      callback = apply_mode,
    })
  end,
}
