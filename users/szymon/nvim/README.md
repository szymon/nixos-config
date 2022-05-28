

## custom mappings

### insert mode


### normal mode


| choard     | action                                                       |
|------------|--------------------------------------------------------------|
| gD         | lua vim.lsp.buf.declaration()                                |
| gd         | lua vim.lsp.buf.definition()                                 |
| K          | lua vim.lsp.buf.hover()                                      |
| gi         | lua vim.lsp.buf.implementation()                             |
| <C-k>      | lua vim.lsp.buf.signature_help()                             |
| <leader>wa | lua vim.lsp.buf.add_workspace_folder()                       |
| <leader>wr | lua vim.lsp.buf.remove_workspace_folder()                    |
| <leader>wl | lua print(vim.inspect(vim.lsp.buf.list_workspace_folders())) |
| <leader>D  | lua vim.lsp.buf.type_definition()                            |
| <leader>rn | lua vim.lsp.buf.rename()                                     |
| <leader>ca | lua vim.lsp.buf.code_action()                                |
| gr         | lua vim.lsp.buf.references()                                 |
| <leader>e  | lua vim.lsp.diagnostic.show_line_diagnostics()               |
| [d         | lua vim.lsp.diagnostic.goto_prev()                           |
| ]d         | lua vim.lsp.diagnostic.goto_next()                           |
| <leader>q  | lua vim.lsp.diagnostic.set_loclist()                         |
| <leader>f  | lua vim.lsp.buf.formatting()                                 |

### other 
