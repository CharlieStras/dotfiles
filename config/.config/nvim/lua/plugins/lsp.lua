-- Resolve the bin dir of NVM's `default` alias (e.g. default -> lts/* ->
-- lts/krypton -> v24.22.1), so Node-based servers don't depend on whichever
-- version `nvm use` activated in the shell that launched nvim.
local function nvm_default_bin()
  local nvm_dir = vim.env.NVM_DIR or vim.fs.joinpath(vim.env.HOME, ".nvm")
  local alias = "default"
  for _ = 1, 10 do
    local file = io.open(vim.fs.joinpath(nvm_dir, "alias", alias))
    if not file then
      break
    end
    alias = vim.trim(file:read("*a"))
    file:close()
  end
  local version = alias:match("^v?(%d+%.%d+%.%d+)$")
  if not version then
    return nil
  end
  local bin = vim.fs.joinpath(nvm_dir, "versions", "node", "v" .. version, "bin")
  return vim.uv.fs_stat(bin) and bin or nil
end

-- Full path under NVM default if installed there, else fall back to $PATH
local function node_cmd(name)
  local bin = nvm_default_bin()
  local path = bin and vim.fs.joinpath(bin, name)
  return path and vim.fn.executable(path) == 1 and path or name
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      vim.lsp.config("vtsls", {
        cmd = { node_cmd("vtsls"), "--stdio" },
      })
      vim.lsp.config("eslint", {
        -- Same as lspconfig's, but with the NVM default fallback; a project's
        -- node_modules/.bin copy still wins
        cmd = function(dispatchers, config)
          local cmd = "vscode-eslint-language-server"
          local local_cmd = config.root_dir
            and vim.fs.joinpath(config.root_dir, "node_modules/.bin", cmd)
          if not (local_cmd and vim.fn.executable(local_cmd) == 1) then
            local_cmd = node_cmd(cmd)
          end
          return vim.lsp.rpc.start({ local_cmd, "--stdio" }, dispatchers)
        end,
      })

      vim.lsp.enable("lua_ls")
      vim.lsp.enable("vtsls")
      vim.lsp.enable("eslint")
    end,
  },
}
