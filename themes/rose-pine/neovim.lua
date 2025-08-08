-- Theme configuration
local plugin_name = "rose-pine/neovim"
local theme_variant = "dawn"  -- Options: "main", "moon", "dawn"
local background = "light"  -- dawn is a light theme

local function apply_theme()
  -- Set background
  vim.o.background = background
  
  -- Try to apply colorscheme
  local ok = pcall(vim.cmd.colorscheme, "rose-pine")
  
  if not ok then
    -- Theme not available, trigger Lazy to install it
    vim.cmd("Lazy install")
    
    -- Simple delayed retry after triggering install
    vim.defer_fn(function()
      vim.o.background = background
      pcall(vim.cmd.colorscheme, "rose-pine")
    end, 1000)
  end
end

-- Apply immediately on file reload
vim.schedule(apply_theme)

return {
  {
    plugin_name,
    name = "rose-pine",
    priority = 1000,
    config = function()
      -- Try setup if available
      pcall(function()
        local rosepine = require("rose-pine")
        if rosepine.setup then
          rosepine.setup({
            variant = theme_variant,
          })
        end
      end)
      vim.o.background = background
      vim.cmd.colorscheme("rose-pine")
    end,
  },
}