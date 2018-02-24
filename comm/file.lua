--
-- Created by IntelliJ IDEA.
-- User: jarlene
-- Date: 2017/5/24
-- Time: 下午10:23
-- To change this template use File | Settings | File Templates.
--

File = {}

local function read(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

local function write(content)
end

local function getFileName(path)
    return string.match(path, "(.+)/[^/]*%.%w+$")
end

local function stripExtension(filename)
    local idx = filename:match(".+()%.%w+$")
    if (idx) then
        return filename:sub(1, idx - 1)
    else
        return filename
    end
end

local function getExtension(filename)
    return filename:match(".+%.(%w+)$")
end

File.read = read
File.write = write
File.getFileName = getFileName
File.stripExtension = stripExtension
File.getExtension = getExtension
return File