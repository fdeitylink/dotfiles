local fennel = require("fennel")
debug.traceback = fennel.traceback
fennel.path = fennel.path .. ";.config/awesome/?.fnl"
table.insert(package.loaders or package.searchers, fennel.searcher)
require("config")
