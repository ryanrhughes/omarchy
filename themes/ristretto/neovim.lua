-- Theme configuration
local plugin_name = "gthelding/monokai-pro.nvim"
local theme_name = "monokai-pro"
local theme_filter = "ristretto"
local background = "dark"

local function apply_theme()
  -- Set background
  vim.o.background = background
  
  -- Try to apply colorscheme
  local ok = pcall(vim.cmd.colorscheme, theme_name)
  
  if not ok then
    -- Theme not available, trigger Lazy to install it
    vim.cmd("Lazy install")
    
    -- Simple delayed retry after triggering install
    vim.defer_fn(function()
      vim.o.background = background
      pcall(vim.cmd.colorscheme, theme_name)
    end, 1000)
  end
end

-- Apply immediately on file reload
vim.schedule(apply_theme)

return {
  {
    plugin_name,
    priority = 1000,
    config = function()
      -- Try setup if available
      pcall(function()
        local monokai = require("monokai-pro")
        if monokai.setup then
          monokai.setup({
            filter = theme_filter,
            override = function()
              return {
                NonText = { fg = "#948a8b" },
                MiniIconsGrey = { fg = "#948a8b" },
                MiniIconsRed = { fg = "#fd6883" },
                MiniIconsBlue = { fg = "#85dacc" },
                MiniIconsGreen = { fg = "#adda78" },
                MiniIconsYellow = { fg = "#f9cc6c" },
                MiniIconsOrange = { fg = "#f38d70" },
                MiniIconsPurple = { fg = "#a8a9eb" },
                MiniIconsAzure = { fg = "#a8a9eb" },
                MiniIconsCyan = { fg = "#85dacc" },
              }
            end,
          })
        end
      end)
      vim.o.background = background
      vim.cmd.colorscheme(theme_name)
    end,
  },
}