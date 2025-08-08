local M = {}

function M.apply_theme(colorscheme, background)
	background = background or "dark"
	vim.o.background = background

	local ok = pcall(function()
		vim.cmd.colorscheme(colorscheme)
	end)

	if not ok then
		-- Theme not available, trigger Lazy to install it
		vim.cmd("Lazy install")

		-- Simple delayed retry after triggering install
		vim.defer_fn(function()
			vim.o.background = background
			pcall(function()
				vim.cmd.colorscheme(colorscheme)
			end)
		end, 1000)
	end
end

return M
