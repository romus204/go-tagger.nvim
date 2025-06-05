vim.api.nvim_create_user_command("AddGoTags", function(opts)
    require("go-tagger").add_tags(opts.line1 - 1, opts.line2)
end, { range = true })

vim.api.nvim_create_user_command("RemoveGoTags", function(opts)
    require("go-tagger").remove_tags(opts.line1 - 1, opts.line2)
end, { range = true })
