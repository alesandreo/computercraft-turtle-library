function get_file_path(path)
    directory, filename, extension = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    return {
        path = directory,
        file = filename,
        ext = extension,
        full_path = directory..filename
    }
end
libraries = {
    {
        file_path = "lib/ale/crafts/crafty.lua",
        paste_bin = ""
    },
    {
        file_path = "lib/ale/turtle/t.lua",
        paste_bin = "Gg3PGyUn"
    }
}

function install_library(library, refresh)
    if not refresh then refresh = false end
    if fs.exist(library.file_path) then
        if refresh then
            fs.delete(library.file_path)
        else
            return true
        end
    end
    local file_info = get_file_path(library.file_path)
    fs.makeDir(file_info.path)
    shell.run("pastebin get "..library.paste_bin.." "..library.file_path)
end

