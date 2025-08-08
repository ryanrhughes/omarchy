-- Theme configuration
local plugin_name = "catppuccin/nvim"
local theme_flavour = "latte"
local background = "light"

local function apply_theme()
  -- Set background
  vim.o.background = background
  
  -- Try to apply colorscheme
  local ok = pcall(vim.cmd.colorscheme, "catppuccin-" .. theme_flavour)
  
  if not ok then
    -- Theme not available, trigger Lazy to install it
    vim.cmd("Lazy install")
    
    -- Simple delayed retry after triggering install
    vim.defer_fn(function()
      vim.o.background = background
      pcall(vim.cmd.colorscheme, "catppuccin-" .. theme_flavour)
    end, 1000)
  end
end

-- Apply immediately on file reload
vim.schedule(apply_theme)

return {
  {
    plugin_name,
    name = "catppuccin",
    priority = 1000,
    config = function()
      -- Try setup if available
      pcall(function()
        local catppuccin = require("catppuccin")
        if catppuccin.setup then
          catppuccin.setup({ flavour = theme_flavour })
        end
      end)
      vim.o.background = background
      vim.cmd.colorscheme("catppuccin-" .. theme_flavour)
    end,
  },
}