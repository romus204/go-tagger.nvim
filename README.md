# go-tagger.nvim

A lightweight Neovim plugin to manage struct field tags in Go source files.

https://github.com/user-attachments/assets/a0295f98-7d15-4ab1-852c-8be877cb0fd7

✅ Features:
- Add new tags (`json`, `xml`, etc.) interactively
- Convert field names to `snake_case`
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
    require("go_tagger").setup({
      skip_private = true, -- Skip unexported fields (starting with lowercase)
    })
  end,
}
```

### packer.nvim

```lua
use {
  "romus204/go-tagger.nvim",
  config = function()
    require("go_tagger").setup()
  end,
}
```

---

## ⚙️ Configuration

```lua
require("go_tagger").setup({
  skip_private = true -- default: true
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

---

## TODO
- [ ] adding other types of writing besides the snake case and configuring them via config  
- [ ] more flexible config settings for different tags
