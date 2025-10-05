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
  -- UI
  { "folke/tokyonight.nvim" },
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
        [[███╗   ██╗██╗   ██╗██╗███╗   ███╗]],
        [[████╗  ██║██║   ██║██║████╗ ████║]],
        [[██╔██╗ ██║██║   ██║██║██╔████╔██║]],
        [[██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        [[██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        [[╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      }
      dashboard.section.buttons.val = {}
      dashboard.section.footer.val = {}
      alpha.setup(dashboard.config)
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- Open (with system handler for binary files)
          vim.keymap.set("n", "o", function()
            local node = api.tree.get_node_under_cursor()
            if not node then return end
            local path = node.absolute_path

            -- extensions to open with system default app
            local external_exts = {
              "pdf", "docx", "pptx", "xlsx", "png", "jpg", "jpeg", "gif", "mp4", "mp3"
            }

            local ext = path:match("^.+%.([^%.]+)$") or ""
            if vim.tbl_contains(external_exts, ext:lower()) then
              vim.fn.jobstart({ "cmd.exe", "/C", "start", "", path }, { detach = true })
            else
              api.node.open.edit(node)
            end
          end, opts("Open"))

          vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
          vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))

          -- Create file in correct folder
          vim.keymap.set("n", "a", function()
            local node = api.tree.get_node_under_cursor()
            if not node then return end
            local path = node.type == "directory" and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
            vim.ui.input({ prompt = "New file name:" }, function(input)
              if not input or input == "" then return end
              local full = path .. "/" .. input .. ".typ"
              vim.cmd("edit " .. vim.fn.fnameescape(full))
              api.tree.reload()
            end)
          end, opts("New File"))
        end,
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
})

-----------------------------------------------------------
-- Settings
-----------------------------------------------------------
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
pcall(vim.cmd, "colorscheme tokyonight")

-----------------------------------------------------------
-- Cache (swap/backup/undo)
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

-- Explorer
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle tree" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })

-- Typst preview (\tt)
map("n", "\\tt", function()
  require("lazy").load({ plugins = { "typst-preview.nvim" } })
  vim.cmd("TypstPreview")
end, { noremap = true, silent = true, desc = "Typst preview" })

-- Typst export menu (\exp)
map("n", "\\exp", typst_export, { noremap = true, silent = true, desc = "Typst export" })

-- Lazygit
map("n", "<leader>g", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

-- Notes shortcuts
map("n", "\\sc", function()
  require("telescope.builtin").find_files({ cwd = "C:/Users/2005j/nvim/Notes" })
end, { desc = "Search Notes" })

map("n", "\\sn", function()
  require("nvim-tree.api").tree.open({ path = "C:/Users/2005j/nvim/Notes", focus = true })
end, { desc = "Notes Explorer" })

-----------------------------------------------------------
-- Auto-detect Typst files
-----------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.typ", "*.typst" },
  callback = function() vim.bo.filetype = "typst" end,
})
