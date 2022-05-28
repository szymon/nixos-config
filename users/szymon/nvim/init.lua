vim.cmd [[source ~/.vimrc]]

require "plugins"
require "lsp_configs"
require "statusline"

vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.spell = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.syntax = "off"

vim.opt.colorcolumn = "88"

vim.opt.laststatus = 3
vim.cmd [[ hi WinSeperator guibg=none ]]

local telescope_actions = require("telescope.actions")
local cb = require 'diffview.config'.diffview_callback

local opts = { noremap = true, silent = true }

local function set_keymap(mode, mapping, action)
    vim.api.nvim_set_keymap(mode, mapping, action, opts)
end

set_keymap("n", "<c-p>", "<cmd>lua require('telescope.builtin').find_files()<cr>")
set_keymap("n", "<leader>rr", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
set_keymap("n", "<leader>gr", "<cmd>lua require('telescope.builtin').grep_string()<cr>")
set_keymap("n", "<leader>;",
    "<cmd>lua require('telescope.builtin').buffers({sort_lastused = true, ignore_current_buffer = true })<cr>")
set_keymap("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
set_keymap("n", "<leader>fk", "<cmd>lua require('telescope.builtin').keymaps()<cr>")
set_keymap("n", "<leader>fs", "<cmd>lua require('telescope.builtin').spell_suggest()<cr>")
set_keymap("n", "<leader>fgc", "<cmd>lua require('telescope.builtin').git_commits()<cr>")
set_keymap("n", "<leader>fgb", "<cmd>lua require('telescope.builtin').git_bcommits()<cr>")
set_keymap("n", "<leader>fgs", "<cmd>lua require('telescope.builtin').git_status()<cr>")

-- vim.api.nvim_set_keymap("n", "<leader>j", "<cmd>cn<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<leader>k", "<cmd>cp<cr>", opts)

vim.cmd [[
" call submode#enter_with('grow/shrink', 'n', '', '<leader><up>', '<C-w>+')
" call submode#enter_with('grow/shrink', 'n', '', '<leader><down>', '<C-w>-')
" call submode#map('grow/shrink', 'n', '', '<down>', '<C-w>-')
" call submode#map('grow/shrink', 'n', '', '<up>', '<C-w>+')

call submode#enter_with('quickfixlist', 'n', '', '<leader>j', '<cmd>cn<cr>')
call submode#enter_with('quickfixlist', 'n', '', '<leader>k', '<cmd>cp<cr>')
call submode#map('quickfixlist', 'n', '', 'j', '<cmd>cn<cr>')
call submode#map('quickfixlist', 'n', '', 'k', '<cmd>cp<cr>')
]]

vim.g.submode_timeout = 0
vim.g.submode_keep_leaving_key = 1

vim.opt.background = "dark"
vim.cmd [[colorscheme gruvbox-material]]

-- insert mode refresh completions (at word, at function call)
-- scrolling window with completions
--
-- some way to define actions on save (format, sort imports...)
vim.g.Illuminate_delay = 300
vim.api.nvim_command [[ hi def link LspReferenceText CursorLine ]]
vim.api.nvim_command [[ hi def link LspReferenceWrite CursorLine ]]
vim.api.nvim_command [[ hi def link LspReferenceRead CursorLine ]]

-- pop-up window for diagnostic is unreadable, now sure how to change it
-- so instead change text color to pink
vim.api.nvim_command [[ hi DiagnosticFloatingError guifg=Pink ]]

-- Telescope_scroll_window {{{
function Telescope_scroll_window(prompt_bufnr, direction, mod)
    local action_state = require 'telescope.actions.state'
    local state = require 'telescope.state'
    -- mostly stolen from https://github.com/nvim-telescope/telescope.nvim/blob/8b02088743c07c2f82aec2772fbd2b3774195448/lua/telescope/actions/set.lua#L168

    local previewer = action_state.get_current_picker(prompt_bufnr).previewer

    -- Check if we actually have a previewer
    if type(previewer) ~= "table" or previewer.scroll_fn == nil then return end

    local status = state.get_status(prompt_bufnr)
    local default_speed = vim.api.nvim_win_get_height(status.preview_win) / mod
    local speed = status.picker.layout_config.scroll_speed or default_speed

    previewer:scroll_fn(math.floor(speed * direction))
end

-- }}}
-- telescope {{{
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<c-f>"] = function(pbn)
                    Telescope_scroll_window(pbn, 1, 1)
                end,
                ["<c-b>"] = function(pbn)
                    Telescope_scroll_window(pbn, -1, 1)
                end,
                ["<c-k>"] = telescope_actions.move_selection_previous,
                ["<c-j>"] = telescope_actions.move_selection_next,
                ["<c-h>"] = telescope_actions.which_key,
                ["<esc>"] = telescope_actions.close
            }
        }
    }
})
-- }}}
-- gitsigns {{{
require("gitsigns").setup {
    signs = {
        add = { hl = "SignAdd", text = "+" },
        change = { hl = "SignChange", text = "~" },
        delete = { hl = "SignDelete", text = "-" },
        topdelete = { hl = "SignDelete", text = "-" },
        changedelete = { hl = "SignChange", text = "~" }
    },
    keymaps = {
        noremap = true,
        buffer = true,
        ["n <leader>hs"] = "<cmd>lua require('gitsigns').stage_hunk()<cr>",
        ["n <leader>hu"] = "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>",
        ["n <leader>hr"] = "<cmd>lua require('gitsigns').reset_hunk()<cr>",
        ["n <leader>hR"] = "<cmd>lua require('gitsigns').reset_buffer()<cr>",
        ["n <leader>hp"] = "<cmd>lua require('gitsigns').preview_hunk()<cr>",
        ["n <leader>hb"] = "<cmd>lua require('gitsigns').blame_line()<cr>"
    },
    watch_gitdir = { interval = 1000 }
}
-- }}}
-- diffview {{{
-- require'diffview'.setup {
--     diff_binaries = false, -- Show diffs for binaries
--     enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
--     file_panel = {
--         position = "left", -- One of 'left', 'right', 'top', 'bottom'
--         width = 35, -- Only applies when position is 'left' or 'right'
--         height = 10, -- Only applies when position is 'top' or 'bottom'
--         listing_style = "tree", -- One of 'list' or 'tree'
--         tree_options = { -- Only applies when listing_style is 'tree'
--             flatten_dirs = true, -- Flatten dirs that only contain one single dir
--             folder_statuses = "only_folded" -- One of 'never', 'only_folded' or 'always'.
--         }
--     },
--     file_history_panel = {
--         position = "bottom",
--         width = 35,
--         height = 16,
--         log_options = {
--             max_count = 256, -- Limit the number of commits
--             follow = false, -- Follow renames (only for single file)
--             all = false, -- Include all refs under 'refs/' including HEAD
--             merges = false, -- List only merge commits
--             no_merges = false, -- List no merge commits
--             reverse = false -- List commits in reverse order
--         }
--     },
--     default_args = { -- Default args prepended to the arg-list for the listed commands
--         DiffviewOpen = {},
--         DiffviewFileHistory = {}
--     },
--     hooks = {}, -- See ':h diffview-config-hooks'
--     key_bindings = {
--         disable_defaults = false, -- Disable the default key bindings
--         -- The `view` bindings are active in the diff buffers, only when the current
--         -- tabpage is a Diffview.
--         view = {
--             ["<tab>"] = cb("select_next_entry"), -- Open the diff for the next file
--             ["<s-tab>"] = cb("select_prev_entry"), -- Open the diff for the previous file
--             ["gf"] = cb("goto_file"), -- Open the file in a new split in previous tabpage
--             ["<C-w><C-f>"] = cb("goto_file_split"), -- Open the file in a new split
--             ["<C-w>gf"] = cb("goto_file_tab"), -- Open the file in a new tabpage
--             ["<leader>e"] = cb("focus_files"), -- Bring focus to the files panel
--             ["<leader>b"] = cb("toggle_files") -- Toggle the files panel.
--         },
--         file_panel = {
--             ["j"] = cb("next_entry"), -- Bring the cursor to the next file entry
--             ["<down>"] = cb("next_entry"),
--             ["k"] = cb("prev_entry"), -- Bring the cursor to the previous file entry.
--             ["<up>"] = cb("prev_entry"),
--             ["<cr>"] = cb("select_entry"), -- Open the diff for the selected entry.
--             ["o"] = cb("select_entry"),
--             ["<2-LeftMouse>"] = cb("select_entry"),
--             ["-"] = cb("toggle_stage_entry"), -- Stage / unstage the selected entry.
--             ["S"] = cb("stage_all"), -- Stage all entries.
--             ["U"] = cb("unstage_all"), -- Unstage all entries.
--             ["X"] = cb("restore_entry"), -- Restore entry to the state on the left side.
--             ["R"] = cb("refresh_files"), -- Update stats and entries in the file list.
--             ["<tab>"] = cb("select_next_entry"),
--             ["<s-tab>"] = cb("select_prev_entry"),
--             ["gf"] = cb("goto_file"),
--             ["<C-w><C-f>"] = cb("goto_file_split"),
--             ["<C-w>gf"] = cb("goto_file_tab"),
--             ["i"] = cb("listing_style"), -- Toggle between 'list' and 'tree' views
--             ["f"] = cb("toggle_flatten_dirs"), -- Flatten empty subdirectories in tree listing style.
--             ["<leader>e"] = cb("focus_files"),
--             ["<leader>b"] = cb("toggle_files")
--         },
--         file_history_panel = {
--             ["g!"] = cb("options"), -- Open the option panel
--             ["<C-A-d>"] = cb("open_in_diffview"), -- Open the entry under the cursor in a diffview
--             ["y"] = cb("copy_hash"), -- Copy the commit hash of the entry under the cursor
--             ["zR"] = cb("open_all_folds"),
--             ["zM"] = cb("close_all_folds"),
--             ["j"] = cb("next_entry"),
--             ["<down>"] = cb("next_entry"),
--             ["k"] = cb("prev_entry"),
--             ["<up>"] = cb("prev_entry"),
--             ["<cr>"] = cb("select_entry"),
--             ["o"] = cb("select_entry"),
--             ["<2-LeftMouse>"] = cb("select_entry"),
--             ["<tab>"] = cb("select_next_entry"),
--             ["<s-tab>"] = cb("select_prev_entry"),
--             ["gf"] = cb("goto_file"),
--             ["<C-w><C-f>"] = cb("goto_file_split"),
--             ["<C-w>gf"] = cb("goto_file_tab"),
--             ["<leader>e"] = cb("focus_files"),
--             ["<leader>b"] = cb("toggle_files")
--         },
--         option_panel = {["<tab>"] = cb("select"), ["q"] = cb("close")}
--     }
-- }
-- }}}
-- treesitter {{{
require 'nvim-treesitter.configs'.setup { ensure_installed = { "python", "lua", "go", "yaml" }, highlight = { enable = true } }
-- }}}
-- better diagnostics {{{

require('trouble').setup {
    position = "bottom", -- position of the list can be: bottom, top, left, right
    height = 10, -- height of the trouble list when position is top or bottom
    width = 50, -- width of the list when position is left or right
    icons = false, -- use devicons for filenames
    mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = ">", -- icon used for open folds
    fold_closed = "v", -- icon used for closed folds
    group = true, -- group results by file
    padding = true, -- add an extra new line on top of the list
    action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q", -- close the list
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r", -- manually refresh
        jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" }, -- open buffer in new split
        open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
        open_tab = { "<c-t>" }, -- open buffer in new tab
        jump_close = { "o" }, -- jump to the diagnostic and close the list
        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
        toggle_preview = "P", -- toggle auto_preview
        hover = "K", -- opens a small popup with the full multiline message
        preview = "p", -- preview the diagnostic location
        close_folds = { "zM", "zm" }, -- close all folds
        open_folds = { "zR", "zr" }, -- open all folds
        toggle_fold = { "zA", "za" }, -- toggle fold of current file
        previous = "k", -- preview item
        next = "j" -- next item
    },
    indent_lines = false, -- add an indent guide below the fold icons
    auto_open = false, -- automatically open the list when you have diagnostics
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
    signs = {
        -- icons / text used for a diagnostic
        error = "error",
        warning = "warning",
        hint = "hint",
        information = "info",
        other = "other"
    },
    use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
}

-- }}}

-- vim: foldmethod=marker :
