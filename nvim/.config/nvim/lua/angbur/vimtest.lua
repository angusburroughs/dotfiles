-- nmap <silent> <leader>t :TestNearest<CR>
-- nmap <silent> <leader>T :TestFile<CR>
-- nmap <silent> <leader>a :TestSuite<CR>
-- nmap <silent> <leader>l :TestLast<CR>
-- nmap <silent> <leader>g :TestVisit<CR>

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)


vim.keymap.set("n", "<leader>T", vim.cmd.TestFile)
vim.keymap.set("n", "<leader>TA", vim.cmd.TestSuite)
vim.keymap.set("n", "<leader>t", vim.cmd.TestLast)

