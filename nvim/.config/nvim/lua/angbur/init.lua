require("angbur.telescope")
require("angbur.nvimtree")
require("angbur.lsp")
require("angbur.colorscheme")
require("angbur.treesitter")
require("angbur.set")
require("angbur.undotree")
require("angbur.vimtest")


vim.keymap.set("n", "<leader>vk", vim.diagnostic.open_float, opts)


P = function(v)
  print(vim.inspect(v))
  return v
end

if pcall(require, 'plenary') then
  RELOAD = require('plenary.reload').reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end

