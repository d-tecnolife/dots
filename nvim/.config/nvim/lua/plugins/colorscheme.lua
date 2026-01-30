return {
  -- Add vim colorschemes collection (includes wildcharm)
  { "vim/colorschemes" },

  -- Set wildcharm as the default
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "wildcharm",
    },
  },
}
