
local native = (term.native and term.native()) or term
local redirectTarget = native

local function wrap( _sFunction )
	return function( ... )
		return redirectTarget[ _sFunction ]( ... )
	end
end

local mainTerm = term
local term = {}

term.redirect = function( target )
    if type( target ) ~= "table" then
        error( "bad argument #1 (expected table, got " .. type( target ) .. ")", 2 ) 
    end
    if target == term then
        error( "term is not a recommended redirect target, try term.current() instead", 2 )
    end
	for k,v in pairs( native ) do
		if type( k ) == "string" and type( v ) == "function" then
			if type( target[k] ) ~= "function" then
				target[k] = function()
					error( "Redirect object is missing method "..k..".", 2 )
				end
			end
		end
	end
	local oldRedirectTarget = redirectTarget
	redirectTarget = target
	return oldRedirectTarget
end

term.current = function()
    return redirectTarget
end

term.native = function()
    -- NOTE: please don't use this function unless you have to.
    -- If you're running in a redirected or multitasked enviorment, term.native() will NOT be
    -- the current terminal when your program starts up. It is far better to use term.current()
    return native
end

mainTerm.defaultFont = {}
mainTerm.currentFont = {}
mainTerm.loadFontFile = function()
    if fs.exists("rom/fonts/term_font.ccfnt") then
        local font_file = fs.open("rom/fonts/term_font.ccfnt", "r")
        if font_file ~= nil then
            --os.debug("Got font")
            local contents = font_file.readAll()
            --os.debug(contents)
            mainTerm.defaultFont = textutils.unserialize(contents)
            font_file.close()
            if mainTerm.defaultFont == nil then error("Font file is in incorrect format") end
        else error("Could not open font file") end
    else error("Could not find font file") end
    mainTerm.currentFont = mainTerm.defaultFont
end

term.redirect(native)

for k,v in pairs( native ) do
	if type( k ) == "string" and type( v ) == "function" then
		if term[k] == nil then
			term[k] = wrap( k )
		end
	end
end
	
local env = _ENV
for k,v in pairs( term ) do
	env[k] = v
end
