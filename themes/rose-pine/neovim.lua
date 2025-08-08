local helper = require("config.theme-helper")

local theme_variant = "dawn"  -- Options: "main", "moon", "dawn"

-- Apply theme immediately when file is loaded
vim.schedule(function()
  helper.apply_theme("rose-pine", "light")  -- dawn is a light theme
end)

return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({ variant = theme_variant })
      vim.o.background = "light"
      vim.cmd.colorscheme("rose-pine")
    end,
  }
}