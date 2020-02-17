-- Bootstrap the compiler
fennel = require("lib.fennel")
table.insert(package.loaders, fennel.make_searcher({correlate=true}))

-- Include the Fennel source file
require("snake.wrap")
