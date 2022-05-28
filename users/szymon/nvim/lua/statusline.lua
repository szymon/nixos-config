local api = vim.api

local M = {}

local active_sep = "blank"

M.separators = { blank = { "", "" } }

M.colors = {
    active = "%#StatusLine#",
    inactive = "%#StatusLineNC#",
    mode = "%#Mode#",
    mode_alt = "%#ModeAlt#",
    git = "%#Git#",
    git_alt = "%#GitAlt#",
    filetype = "%#Filetype#",
    filetype_alt = "%#FiletypeAlt#",
    line_col = "%#LineCol#",
    line_col_alt = "%#LineColAlt#"
}

M.truncate_width = setmetatable({ mode = 80, git_status = 90, filename = 140, line_col = 60 }, {
    __index = function()
        return 80
    end
})

M.is_truncated = function(_, width)
    local current_width = api.nvim_win_get_width(0)
    return current_width < width
end

M.modes = setmetatable({
    ["n"] = { "Normal", "N " },
    ["no"] = { "Normal·Operator Pending", "NP" },
    ["v"] = { "Visual", "V " },
    ["V"] = { "V·Line", "VL" },
    [""] = { "V·Blck", "VL" },
    ["s"] = { "Select", "S " },
    ["S"] = { "S·Line", "SL" },
    [""] = { "S·Block", "SB" },
    ["i"] = { "Insert", "I " },
    ["R"] = { "Replace", "R " },
    ["Rv"] = { "V·Replace", "VR" },
    ["c"] = { "CMD   ", "C " },
    ["cv"] = { "Vim Ex", "X " },
    ["ce"] = { "Ex", "EX" },
    ["r"] = { "Prompt", "P " },
    ["rm"] = { "More", "M " },
    ["r?"] = { "Confirm", "C " },
    ["!"] = { "Shell", "S " },
    ["t"] = { "Terminal", "T " }
}, {
    __index = function()
        return { "Unknown", "U" }
    end
})

M.get_current_mode = function(self)
    local current_mode = api.nvim_get_mode().mode

    if self:is_truncated(self.truncate_width.mode) then return string.format(" %s ", self.modes[current_mode][2]):upper() end
    return string.format(" %s ", self.modes[current_mode][1]):upper()
end

M.get_git_status = function(self)
    local signs = vim.b.gitsigns_status_dict or { head = "", added = 0, changed = 0, removed = 0 }
    local is_head_empty = signs.head ~= ""

    if self:is_truncated(self.truncate_width.git_status) then return is_head_empty and string.format(" %s ", signs.head or "") or "" end
    return is_head_empty and string.format(" +%s ~%s -%s | %s ", signs.added, signs.changed, signs.removed, signs.head) or ""
end

M.get_filename = function(self)
    if self:is_truncated(self.truncate_width.filename) then return " %<%f " end
    return " %<%F "
end

M.get_filetype = function()
    -- local file_name, file_ext = fn.expand("%"), fn.expand("%:e")
    -- local icon = require("nvim-web-devicons").get_icon(file_name, file_ext, { default = true })
    local filetype = vim.bo.filetype

    if filetype == "" then return "" end
    return string.format(" %s ", filetype):lower()
end

M.get_line_col = function(self)
    if self:is_truncated(self.truncate_width.line_col) then return " %l:%c " end
    return " Ln %3l, Col %2c "
end

M.set_active = function(self)
    local colors = self.colors
    local mode = colors.mode .. self:get_current_mode()
    local mode_alt = colors.mode_alt .. self.separators[active_sep][1]
    local git = colors.git .. self:get_git_status()
    local git_alt = colors.git_alt .. self.separators[active_sep][1]
    local filename = colors.inactive .. self:get_filename()
    local filetype_alt = colors.filetype_alt .. self.separators[active_sep][2]
    local filetype = colors.filetype .. self:get_filetype()
    local line_col_alt = colors.line_col_alt .. self.separators[active_sep][2]
    local line_col = colors.line_col .. self:get_line_col()

    return table.concat({ colors.active, mode, mode_alt, git, git_alt, "%=", filename, "%=", filetype_alt, filetype, line_col_alt, line_col })
end

M.set_inactive = function(self)
    return self.colors.inactive .. "%= %F %="
end

Statusline = setmetatable(M, {
    __call = function(statusline, mode)
        if mode == "active" then return statusline:set_active() end
        if mode == "inactive" then return statusline:set_inactive() end
    end
})

vim.cmd [[
    augroup Statusline
    au!
    au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
    au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
    augroup END
]]
