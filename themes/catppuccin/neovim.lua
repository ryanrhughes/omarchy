local helper = require("config.theme-helper")

local theme_flavour = "mocha"  -- Options: "latte", "frappe", "macchiato", "mocha"

-- Apply theme immediately when file is loaded
vim.schedule(function()
  helper.apply_theme("catppuccin-" .. theme_flavour, "dark")
end)

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = theme_flavour })
      vim.o.background = "dark"
      vim.cmd.colorscheme("catppuccin-" .. theme_flavour)
    end,
  }
}