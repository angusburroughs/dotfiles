local cmp = require("cmp")
local source_mapping = {
	buffer = "[Buffer]",
	nvim_lsp = "[LSP]",
	-- nvim_lua = "[Lua]",
	path = "[Path]",
}

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},

    -- these mappings don't work, but the buffer based suggestions do
	mapping = {
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
        ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ['<CR>'] = cmp.mapping.confirm({ select = true })
	},
    formatting = {
        format = function(entry, vim_item)
            local menu = source_mapping[entry.source.name]
            vim_item.menu = menu
            return vim_item
        end
    },
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
	},
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local on_attach = function(client, bufnr)
    require'lsp_signature'.on_attach({
      bind = true,
      handler_opts = {
          border = "rounded"
      }
    }, bufnr)    
end


local golang_setup = {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = { gopls = {
      buildFlags = {"-tags=integration,unit,acceptance"}
    }
  }
}
require'lspconfig'.gopls.setup(golang_setup)

require'lspconfig'.jedi_language_server.setup{}

require('lspconfig').terraformls.setup({
    filetypes = { "terraform", "tf" }
})
