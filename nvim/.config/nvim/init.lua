-- Minimal Neovim config (0.12+): mini.nvim + built-in LSP, with Helix-style bindings
-- Leader keys mirror Helix's space mode; the same mappings exist in ~/.vimrc as a fallback

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Plugins
-- - Pinned in nvim-pack-lock.json (commit it); update with :lua vim.pack.update()
-- - Parsers are tied to the nvim-treesitter version, so rebuild them whenever it updates
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
            if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
            vim.cmd("TSUpdate")
        end
    end,
})
vim.pack.add({
    "https://github.com/echasnovski/mini.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    "https://github.com/christoomey/vim-tmux-navigator", -- Pairs with the tmux plugin
    { src = "https://github.com/dracula/vim", name = "dracula" },
}, { confirm = false })

-- Options
local o = vim.opt
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.scrolloff = 5
o.termguicolors = true
o.winborder = "rounded"
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 300
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.completeopt = { "menuone", "noselect", "popup", "fuzzy" }

-- - Indentation
o.expandtab = true
o.tabstop = 4
o.shiftwidth = 0   -- Use tabstop
o.softtabstop = -1 -- Use tabstop
o.smartindent = true

vim.cmd.colorscheme("dracula")

-- - Clipboard: system clipboard locally, OSC 52 over SSH (tmux has set-clipboard on)
o.clipboard = "unnamedplus"
if vim.env.SSH_TTY then
    vim.g.clipboard = "osc52"
end

-- Filetypes Neovim misdetects (*.tf is TinyFugue by default) or doesn't know
vim.filetype.add({ extension = { tf = "terraform", j2 = "jinja" } })

-- Treesitter
-- - Parsers are compiled locally, which needs the tree-sitter CLI (>= 0.26.1) and a C compiler.
--   install.sh installs them up front; without those tools buffers fall back to regex highlighting
vim.g.ts_parsers = {
    "c", "cpp", "cuda", "python", "cmake", "make", "bash", "lua",
    "markdown", "markdown_inline", "terraform", "hcl", "yaml", "jinja", "jinja_inline",
    "toml", "json", "diff", "gitcommit", "vim", "vimdoc", "query",
}
if vim.fn.executable("tree-sitter") == 1 and vim.fn.executable("cc") == 1 then
    -- Pick up any parsers added to the list above (no-op once installed); skipped when headless
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
            if #vim.api.nvim_list_uis() > 0 then
                require("nvim-treesitter").install(vim.g.ts_parsers)
            end
        end,
    })
end
vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
})

-- mini.nvim modules
require("mini.statusline").setup() -- Shows mode (NORMAL/INSERT), git, diagnostics
require("mini.diff").setup()       -- Git gutter, ]h/[h to jump hunks
require("mini.pairs").setup()      -- Auto-close brackets/quotes
require("mini.ai").setup()         -- Better text objects: a/i + f(unction), a(rgument), q(uote)...
require("mini.surround").setup()   -- sa/sd/sr: add/delete/replace surroundings (Helix ms/md/mr)
require("mini.extra").setup()
require("mini.pick").setup()
require("mini.files").setup()
vim.ui.select = MiniPick.ui_select -- Code actions etc. go through the picker

-- - Which-key style popups (Helix shows these for every prefix)
local miniclue = require("mini.clue")
miniclue.setup({
    triggers = {
        { mode = "n", keys = "<Leader>" },
        { mode = "x", keys = "<Leader>" },
        { mode = "n", keys = "g" },
        { mode = "x", keys = "g" },
        { mode = "n", keys = "[" },
        { mode = "n", keys = "]" },
        { mode = "n", keys = "z" },
        { mode = "n", keys = "<C-w>" },
        { mode = "n", keys = "'" },
        { mode = "n", keys = '"' },
        { mode = "i", keys = "<C-r>" },
    },
    clues = {
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
    },
    window = { delay = 300 },
})

-- Keymaps
local map = vim.keymap.set
local pick, extra = MiniPick.builtin, MiniExtra.pickers

-- - Space mode (follows Helix's layout where Neovim has an equivalent)
map("n", "<leader>f", function() pick.files() end, { desc = "Find file" })
map("n", "<leader>b", function() pick.buffers() end, { desc = "Buffers" })
map("n", "<leader>/", function() pick.grep_live() end, { desc = "Search" })
map("n", "<leader>'", function() pick.resume() end, { desc = "Last picker" })
map("n", "<leader>j", function() extra.list({ scope = "jump" }) end, { desc = "Jumplist" })
map("n", "<leader>g", function() extra.git_hunks() end, { desc = "Changed hunks" })
map("n", "<leader>d", function() extra.diagnostic({ scope = "current" }) end, { desc = "Diagnostics (buffer)" })
map("n", "<leader>D", function() extra.diagnostic({ scope = "all" }) end, { desc = "Diagnostics (all)" })
map("n", "<leader>s", function() extra.lsp({ scope = "document_symbol" }) end, { desc = "Symbols" })
map("n", "<leader>S", function() extra.lsp({ scope = "workspace_symbol" }) end, { desc = "Workspace symbols" })
map("n", "<leader>?", function() extra.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>e", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "File explorer (here)" })
map("n", "<leader>E", function() MiniFiles.open() end, { desc = "File explorer (cwd)" })
map("n", "<leader>k", vim.lsp.buf.hover, { desc = "Hover docs" })
map("n", "<leader>r", vim.lsp.buf.rename, { desc = "Rename symbol" })
map({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action, { desc = "Code action" })
map({ "n", "x" }, "<leader>=", function() vim.lsp.buf.format() end, { desc = "Format" })
map("n", "<leader>c", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<leader>c", "gc", { remap = true, desc = "Toggle comment" })
map("n", "<leader>w", "<C-w>", { remap = true, desc = "+Window" })

-- - Goto mode: Helix's gh/gl/gs line motions (Vim's gh/gs are rarely-used select/sleep)
map({ "n", "x", "o" }, "gh", "0", { desc = "Goto line start" })
map({ "n", "x", "o" }, "gl", "$", { desc = "Goto line end" })
map({ "n", "x", "o" }, "gs", "^", { desc = "Goto first non-blank" })
-- - LSP gotos; Neovim already provides grr/gri/grt/grn/gra and ]d/[d
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto type definition" })

-- - Misc Helix-isms
map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>")
map("i", "<Tab>", function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end, { expr = true })
map("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end, { expr = true })

-- - lazygit in a floating terminal (carried over from the old Helix config)
if vim.fn.executable("lazygit") == 1 then
    map("n", "<C-g>", function()
        vim.cmd("silent! wall")
        local buf = vim.api.nvim_create_buf(false, true)
        local w, h = math.floor(vim.o.columns * 0.9), math.floor(vim.o.lines * 0.9)
        vim.api.nvim_open_win(buf, true, {
            relative = "editor", width = w, height = h,
            row = math.floor((vim.o.lines - h) / 2), col = math.floor((vim.o.columns - w) / 2),
        })
        vim.fn.jobstart({ "lazygit" }, {
            term = true,
            on_exit = function()
                vim.api.nvim_buf_delete(buf, { force = true })
                vim.cmd("checktime")
            end,
        })
        vim.cmd.startinsert()
    end, { desc = "lazygit" })
end

-- LSP
-- - Inline diagnostics like Helix
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- - Auto-completion as you type
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

-- - Machine-specific overrides (e.g. a different clangd), loaded before servers are enabled
for _, kind in ipairs({ "personal", "work" }) do
    local override = (vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")) .. "/nvim-overrides/" .. kind .. ".lua"
    if vim.uv.fs_stat(override) then dofile(override) end
end

-- - Enable whichever servers are installed, so the config works unchanged on bare remotes
local servers = {
    "clangd",          -- C/C++/CUDA
    "basedpyright",    -- Python (or "pyright")
    "bashls",          -- Shell
    "lua_ls",          -- Lua (this config)
    "neocmakelsp",     -- CMake
    "terraformls",     -- Terraform
    "yamlls",          -- YAML/Ansible
    "taplo",           -- TOML
    "marksman",        -- Markdown
    "fortls",          -- Fortran
    "mlir_lsp_server", -- MLIR
}
for _, name in ipairs(servers) do
    local cmd = (vim.lsp.config[name] or {}).cmd
    if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1 then
        vim.lsp.enable(name)
    end
end

-- - Teach lua_ls about the Neovim runtime so `vim` isn't flagged as undefined
vim.lsp.config("lua_ls", {
    settings = { Lua = { runtime = { version = "LuaJIT" }, workspace = { library = { vim.env.VIMRUNTIME } } } },
})
