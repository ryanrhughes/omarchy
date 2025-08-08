local helper = require("config.theme-helper")

-- Apply theme immediately when file is loaded
vim.schedule(function()
  helper.apply_theme("everforest", "dark")
end)

return {
  {
    "neanias/everforest-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("everforest").setup({ background = "soft" })
      vim.o.background = "dark"
      vim.cmd.colorscheme("everforest")
    end,
  }
}