function get_file_path(path)
    directory, filename, extension = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    return {
        path = directory,
        file = filename,
        ext = extension,
        full_path = directory..filename
    }
end