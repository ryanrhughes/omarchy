local helper = require("config.theme-helper")

local theme_style = "vulgaris"

-- Apply theme immediately when file is loaded
vim.schedule(function()
  helper.apply_theme("bamboo", "dark")
end)

return {
  {
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("bamboo").setup({ style = theme_style })
      vim.o.background = "dark"
      vim.cmd.colorscheme("bamboo")
    end,
  }
}