function script_path()
   return debug.getinfo(2, "S").source:sub(2):match("(.*/)")
end

package.path = package.path .. ";" .. script_path() .. "fennel-1.3.0/?.lua"
fennel = require("fennel")
fennel.install()
fennel.dofile(script_path() .. "config.fnl")
