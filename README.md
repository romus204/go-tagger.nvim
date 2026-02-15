# go-tagger.nvim

A lightweight Neovim plugin to manage struct field tags in Go source files.

https://github.com/user-attachments/assets/a0295f98-7d15-4ab1-852c-8be877cb0fd7

✅ Features:
- Add new tags (`json`, `xml`, etc.) interactively
- Convert field names to `snake_case`,`camelCase`,`kebab-case`, `PascalCase`
- Preserve existing tags
- Skip unexported (private) fields by default
- Remove specific tags or all tags from selected lines
- **Visual mode support for multi-line editing**

---

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "romus204/go-tagger.nvim",
  config = function()
    require("go-tagger").setup({
      skip_private = true, -- Skip unexported fields (starting with lowercase)
      casing = "camelCase", -- Global casing setting
      tags = { -- Per tag setting override
        json = {
          casing = "camelCase" -- json tags should use camelCase
        },
        xml = {
          casing = "snake_case" -- xml tags should use snake_case
        }
      }
    })
  end,
}
```

### packer.nvim

```lua
use {
  "romus204/go-tagger.nvim",
  config = function()
    require("go-tagger").setup({
      skip_private = true, -- Skip unexported fields (starting with lowercase)
      casing = "camelCase", -- Global casing setting
      tags = { -- Per tag setting override
        json = {
          casing = "camelCase" -- json tags should use camelCase
        },
        xml = {
          casing = "snake_case" -- xml tags should use snake_case
        }
      }
    })
  end,
}
```

---

## ⚙️ Configuration

Default config:
```lua
require("go-tagger").setup({
      skip_private = true, -- Skip unexported fields (starting with lowercase)
      casing = "snake_case", -- Global casing setting
      tags = {} -- Per tag setting override
})
```

Example:
```lua
require("go-tagger").setup({
      skip_private = false, -- NO Skip unexported fields (starting with lowercase)
      casing = "camelCase", -- Global casing setting
      tags = { -- Per tag setting override
        json = {
          casing = "camelCase" -- json tags should use camelCase
        },
        xml = {
          casing = "snake_case" -- xml tags should use snake_case
        }
      }
})
```


---

## 🚀 Usage

### Visual Mode Support

You can use the plugin in **visual mode** to tag or untag multiple lines at once. Just select the fields and run one of the available commands.

---

## 🔧 Commands

### `:AddGoTags`

Adds tags to selected struct fields.

- Works in visual mode over one or more lines.
- Prompts you to enter tag names, separated by commas (e.g., `json,xml`).
- Ignores unexported fields if `skip_private = true`.

```vim
:AddGoTags
```

You’ll be prompted:

```
tag(s): json,xml
```

Resulting output:

```go
ID   int    `json:"id" xml:"id"`
Name string `json:"name" xml:"name"`
```

---

### `:RemoveGoTags`

Removes tags from selected struct fields.

- Works in visual mode over one or more lines.
- Prompts you to enter a tag name to remove (e.g., `json`).
- Leave input blank to remove **all tags**.

```vim
:RemoveGoTags
```

Prompt:

```
tag: json
```

Result:

```go
ID   int    `xml:"id"`
Name string `xml:"name"`
```

---

## 🔑 Example keybindings

```lua
vim.keymap.set("v", "<leader>at", ":AddGoTags<CR>", { desc = "Add Go struct tags", silent = true })
vim.keymap.set("v", "<leader>rt", ":RemoveGoTags<CR>", { desc = "Remove Go struct tags", silent = true })
```
