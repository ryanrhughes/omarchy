local helper = require("config.theme-helper")

-- Apply theme immediately when file is loaded
vim.schedule(function()
  helper.apply_theme("tokyonight", "dark")
end)

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "dark"
      vim.cmd.colorscheme("tokyonight")
    end,
  }
}