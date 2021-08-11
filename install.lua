-- https://pastebin.com/hGkQUxWF
if not fs then
    fs = {
        exists = function (file_path)
            local file_handle
            file_handle = io.open(file_path, 'r')
            if file_handle then
                io.close(file_handle)
                return true
            end
            return false
        end,
        delete = function (file_path)
            return os.remove(file_path)
        end
    }
end
if not shell then
    shell = {
        run = function (cli)
            print(cli)
        end
    }
end
Library = {
    full_path = "",
    path = "",
    ext = "",
    filename = "",
    paste_bin = "",
}

Library.__index = Library

function Library:new(library_data)
    library_data = library_data or {}

    local library = {}
    setmetatable(library, Library)
    local path_data = self.get_file_path(library_data.file_path)
    library.paste_bin = library_data.paste_bin or nil
    library.path = path_data.path
    library.full_path = path_data.full_path
    library.filename = path_data.filename
    library.ext = path_data.ext
    return library
end

function Library.get_file_path(path)
    local directory, filename, extension = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    return {
        path = directory,
        file = filename,
        ext = extension,
        full_path = directory..filename
    }
end

function Library:exists()
    return fs.exists(self.full_path)
end

function Library:delete()
    if self:exists() then
        fs.delete(self.full_path)
    end
    return true
end

function Library:download()
    fs.makeDir(self.path)
    local cli = "pastebin get "..self.paste_bin.." "..self.full_path
    print(cli)
    shell.run(cli)
end

function Library:refresh()
    return self:install(true)
end


function Library:install(refresh)
    if not refresh then refresh = false end
    if refresh then
        self:delete()
    end
    self:download()
end
Libraries = {
    {
        file_path = "lib/ale/mock/mock.lua",
        paste_bin = "LJnVWtiw"
    },
    {
        file_path = "lib/ale/turtle/blocklist.lua",
        paste_bin = "tnXQrtpQ"
    },
    {
        file_path = "lib/ale/turtle/history.lua",
        paste_bin = "TFLLgAK5"
    },
    {
        file_path = "lib/ale/turtle/inventory.lua",
        paste_bin = "Xt9Z2Dk8"
    },
    {
        file_path = "lib/ale/turtle/miner.lua",
        paste_bin = "tgD36Vx7"
    },
    {
        file_path = "lib/ale/turtle/position.lua",
        paste_bin = "xzFNmXX1"
    },
    {
        file_path = "lib/ale/turtle/turtle.lua",
        paste_bin = "iEcuJ70J"
    },
    {
        file_path = "lib/ale/ar.lua",
        paste_bin = "vr5qBvMP"
    },
    {
        file_path = "lib/ale/ale.lua",
        paste_bin = "x1LfzQNz"
    },
    {
        file_path = "lib/ale/config.lua",
        paste_bin = "w0T3h4a8"
    },
    {
        file_path = "lib/ale/crafty.lua",
        paste_bin = "MqCphaSj"
    },
    {
        file_path = "lib/ale/logger.lua",
        paste_bin = "wy7Vut3x"
    },
    {
        file_path = "lib/ale/turtle.lua",
        paste_bin = "mZYfaWLA"
    },
    {
        file_path = "lib/ale/utils.lua",
        paste_bin = "PEVfiaAa"
    },
    {
        file_path = "install.lua",
        paste_bin = "hGkQUxWF"
    },
}

for k, lib in pairs(Libraries) do
    Lib = Library:new(lib)
    Lib:refresh()
end

if not require('lib.ale.ale') then
    error("Failed to properly install.")
end