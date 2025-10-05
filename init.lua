-----------------------------------------------------------
-- Leader
-----------------------------------------------------------
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-----------------------------------------------------------
-- Bootstrap lazy.nvim
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- Plugins
-----------------------------------------------------------
require("lazy").setup({
  -- Theme
  { "bluz71/vim-nightfly-colors", name = "nightfly" },
  { "catppuccin/nvim", name = "catppuccin" },

  -- UI
  { "nvim-lualine/lualine.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        [[ ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄   ▄▄   ▄▄    ▄▄    ▄ ▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄ ]],
        [[█       █  █ █  █       █   ▄  █ █  █ █  █  █  █  █ █   █       █       █      █]],
        [[█    ▄▄▄█  █▄█  █    ▄▄▄█  █ █ █ █  █▄█  █  █   █▄█ █   █   ▄▄▄▄█   ▄▄▄▄█  ▄   █]],
        [[█   █▄▄▄█       █   █▄▄▄█   █▄▄█▄█       █  █       █   █  █  ▄▄█  █  ▄▄█ █▄█  █]],
        [[█    ▄▄▄█       █    ▄▄▄█    ▄▄  █▄     ▄█  █  ▄    █   █  █ █  █  █ █  █      █]],
        [[█   █▄▄▄ █     ██   █▄▄▄█   █  █ █ █   █    █ █ █   █   █  █▄▄█ █  █▄▄█ █  ▄   █]],
        [[█▄▄▄▄▄▄▄█ █▄▄▄█ █▄▄▄▄▄▄▄█▄▄▄█  █▄█ █▄▄▄█    █▄█  █▄▄█▄▄▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█▄█ █▄▄█]],
        [[]],
        [[                ▄▄▄ ▄▄▄▄▄▄▄    ▄▄▄▄▄▄    ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄▄▄▄   ]],
        [[                █   █       █  █      █  █       █       █      █   ▄  █  ]],
        [[                █   █  ▄▄▄▄▄█  █  ▄   █  █  ▄▄▄▄▄█▄     ▄█  ▄   █  █ █ █  ]],
        [[                █   █ █▄▄▄▄▄   █ █▄█  █  █ █▄▄▄▄▄  █   █ █ █▄█  █   █▄▄█▄ ]],
        [[                █   █▄▄▄▄▄  █  █      █  █▄▄▄▄▄  █ █   █ █      █    ▄▄  █]],
        [[                █   █▄▄▄▄▄█ █  █  ▄   █   ▄▄▄▄▄█ █ █   █ █  ▄   █   █  █ █]],
        [[                █▄▄▄█▄▄▄▄▄▄▄█  █▄█ █▄▄█  █▄▄▄▄▄▄▄█ █▄▄▄█ █▄█ █▄▄█▄▄▄█  █▄█]],
      }
      dashboard.section.buttons.val = {}
      dashboard.section.footer.val = {}
      alpha.setup(dashboard.config)
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    config = function()
      require("nvim-tree").setup({
        renderer = {
          highlight_git = true,
          highlight_opened_files = "all",
        },
      })
      require("catppuccin").setup({
        integrations = { nvimtree = true }
      })
    end,
  },

  -- Telescope
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP
  { "neovim/nvim-lspconfig" },

  -- Typst preview
  { "chomosuke/typst-preview.nvim", ft = { "typst" }, build = "npm install --prefix app" },

  -- Lazygit
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
    config = function() require("telescope").load_extension("lazygit") end,
  },

  -- Completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
})

-----------------------------------------------------------
-- Settings
-----------------------------------------------------------
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
pcall(vim.cmd, "colorscheme nightfly")

-----------------------------------------------------------
-- Cache
-----------------------------------------------------------
local cache_dir = vim.fn.expand("C:/Users/2005j/nvim/cache")
if vim.fn.isdirectory(cache_dir) == 0 then
  vim.fn.mkdir(cache_dir, "p")
end
vim.opt.directory = cache_dir .. "/swap//"
vim.opt.backupdir = cache_dir .. "/backup//"
vim.opt.undodir = cache_dir .. "/undo//"
vim.opt.undofile = true

-----------------------------------------------------------
-- Completion (nvim-cmp + LuaSnip)
-----------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

-- Typst snippet: \f → #ce("")
luasnip.add_snippets("typst", {
  luasnip.snippet({ trig = "\\f", wordTrig = true }, {
    luasnip.text_node('#ce("'),
    luasnip.insert_node(1),
    luasnip.text_node('")'),
  }),
})

cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "luasnip" },
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})

-----------------------------------------------------------
-- Telescope Typst Export (\exp)
-----------------------------------------------------------
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local function typst_export()
  pickers.new({}, {
    prompt_title = "Export Typst",
    finder = finders.new_table({ results = { "pdf", "png", "svg" } }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not sel or not sel.value then return end
        local filepath = vim.fn.expand("%:p")
        local outpath = vim.fn.expand("%:p:r") .. "." .. sel.value
        vim.fn.jobstart({ "typst", "compile", "--format", sel.value, filepath, outpath }, {
          on_exit = function(_, code)
            vim.schedule(function()
              if code == 0 then
                vim.notify("Exported → " .. outpath, vim.log.levels.INFO)
              else
                vim.notify("Export failed", vim.log.levels.ERROR)
              end
            end)
          end,
        })
      end)
      return true
    end,
  }):find()
end

-----------------------------------------------------------
-- Keymaps
-----------------------------------------------------------
local map = vim.keymap.set
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle tree" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
map("n", "\\tt", function()
  require("lazy").load({ plugins = { "typst-preview.nvim" } })
  vim.cmd("TypstPreview")
end, { noremap = true, silent = true, desc = "Typst preview" })
map("n", "\\exp", typst_export, { noremap = true, silent = true, desc = "Typst export" })
map("n", "<leader>g", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
map("n", "\\sc", function()
  require("telescope.builtin").find_files({ cwd = "C:/Users/2005j/nvim/Notes" })
end, { desc = "Search Notes" })
map("n", "\\sn", function()
  require("nvim-tree.api").tree.open({ path = "C:/Users/2005j/nvim/Notes", focus = true })
end, { desc = "Notes Explorer" })

-----------------------------------------------------------
-- Auto-detect Typst files + Typst keymaps
-----------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.typ", "*.typst" },
  callback = function() vim.bo.filetype = "typst" end,
})

vim.api.nvim_create_autocmd("SwapExists", { callback = function() vim.v.swapchoice = 'd' end })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function()
    local opts = { noremap = true, silent = true, buffer = true }

    -- Insert imports if missing (\symbols)
    vim.keymap.set({"n","i"}, "\\symbols", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      local has_whalogen, has_physica = false, false
      for _, l in ipairs(lines) do
        if l:match("whalogen") then has_whalogen = true end
        if l:match("physica") then has_physica = true end
      end

      local insert_lines = {}
      if not has_whalogen then
        table.insert(insert_lines, '#import "@preview/whalogen:0.3.0": ce')
      end
      if not has_physica then
        table.insert(insert_lines, '#import "@preview/physica:0.9.6": *')
      end

      if #insert_lines > 0 then
        table.insert(insert_lines, "")
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, insert_lines)
      end
    end, opts)

    -- \ + Tab → expand to Typst block indentation
    vim.keymap.set("i", "\\<Tab>", function()
      vim.api.nvim_put({ "#block(inset x 2)[]" }, "c", true, true)
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Left>", true, false, true),
        "n",
        true
      )
    end, { buffer = true, noremap = true, silent = true, desc = "Typst block indentation" })
  end,
})

