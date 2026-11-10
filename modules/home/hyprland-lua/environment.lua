local cursor = require("cursor")

hl.env("XCURSOR_THEME", cursor.name)
hl.env("XCURSOR_SIZE", tostring(cursor.size))
