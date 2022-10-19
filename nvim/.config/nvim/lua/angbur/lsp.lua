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
  settings = { gopls = {
      buildFlags = {"-tags=integration,unit,acceptance"}
    }
  }
}
require'lspconfig'.gopls.setup(golang_setup)

require'lspconfig'.jedi_language_server.setup{}
