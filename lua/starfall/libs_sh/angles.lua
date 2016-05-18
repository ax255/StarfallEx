SF.Angles = {}

--- Angle Type
-- @shared
local ang_methods, ang_metamethods = SF.Typedef( "Angle" )

local function wrap( tbl )
	return setmetatable( { (tonumber(tbl[1]) or 0), (tonumber(tbl[2]) or 0), (tonumber(tbl[3]) or 0) }, ang_metamethods )
end

local function unwrap( obj )
	return Angle( (obj[1] or 0), (obj[2] or 0), (obj[3] or 0) )
end

local function awrap( ang )
	return wrap( { ang.pitch, ang.yaw, ang.roll } )
end

SF.AddObjectWrapper( debug.getregistry().Angle, ang_metamethods, awrap )
SF.AddObjectUnwrapper( ang_metamethods, unwrap )

SF.DefaultEnvironment.Angle = function ( ... )
	return wrap( { ... } )
end

SF.Angles.Wrap 	= awrap
SF.Angles.Unwrap = unwrap
SF.Angles.Methods = ang_methods
SF.Angles.Metatable = ang_metamethods

local dgetmeta = debug.getmetatable

-- Lookup table.
-- Index 1->6 have associative pyr for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
local pyr = { p = 1, y = 2, r = 3, pitch = 1, yaw = 2, roll = 3 }

--- __newindex metamethod
function ang_metamethods.__newindex ( t, k, v )
	if pyr[ k ] then
		rawset( t, pyr[ k ], v )
	else
		rawset( t, k, v )
	end
end

local _p = ang_metamethods.__methods

--- __index metamethod
function ang_metamethods.__index ( t, k )
	if pyr[ k ] then
		return rawget( t, pyr[ k ] )
	else
		return _p[k]
	end
end

local table_concat = table.concat

local math_nAng = math.NormalizeAngle
local function normalizedAngTable( tbl )
	return { math_nAng( tbl[1] ), math_nAng( tbl[2] ), math_nAng( tbl[3] ) }
end

--- tostring metamethod
-- @return string representing the angle.
function ang_metamethods.__tostring ( a )
	return table_concat( a, ' ', 1, 3 )
end

--- __mul metamethod ang1 * n.
-- @param n Number to multiply by.
-- @return resultant angle.
function ang_metamethods.__mul ( a, n )
	SF.CheckType( n, "number" )

	return wrap( normalizedAngTable( { a[1]*n, a[2]*n, a[3]*n } ) )
end

--- __div metamethod ang1 / n.
-- @param n Number to divided by.
-- @return resultant angle.
function ang_metamethods.__div ( a, n )
	SF.CheckType( a, ang_metamethods )
	SF.CheckType( n, "number" )

	return wrap( { a[1]/n, a[2]/n, a[3]/n } )
end

--- __unm metamethod -ang.
-- @return resultant angle.
function ang_metamethods.__unm ( a )
	return wrap( { -a[1], -a[2], -a[3] } )
end

--- __eq metamethod ang1 == ang2.
-- @param a Angle to check against.
-- @return bool
function ang_metamethods.__eq ( a, b )
	if dgetmeta(a) ~= ang_metamethods then return false end
	if dgetmeta(b) ~= ang_metamethods then return false end

	if #a ~= #b then return false end

	for k, v in pairs( a ) do
		if v ~= b[k] then return false end
	end

	return true
end

--- __add metamethod ang1 + ang2.
-- @param a Angle to add.
-- @return resultant angle.
function ang_metamethods.__add ( a, b )
	SF.CheckType( a, ang_metamethods )
	SF.CheckType( b, ang_metamethods )

	return wrap( { a[1]+b[1], a[2]+b[2], a[3]+b[3] } )
end

--- __sub metamethod ang1 - ang2.
-- @param a Angle to subtract.
-- @return resultant angle.
function ang_metamethods.__sub ( a, b )
	SF.CheckType( a, ang_metamethods )
	SF.CheckType( b, ang_metamethods )

	return wrap( { a[1]-b[1], a[2]-b[2], a[3]-b[3] } )
end


--- Return the Forward Vector ( direction the angle points ).
-- @return vector normalised.
function ang_methods:getForward ()
	return SF.WrapObject( unwrap( self ):Forward() )
end

--- Returns if p,y,r are all 0.
-- @return boolean
function ang_methods:isZero ()
	if self[1] ~= 0 then return false
	elseif self[2] ~= 0 then return false
	elseif self[3] ~= 0 then return false
	end

	return true
end

--- Normalise angles eg (0,181,1) -> (0,-179,1).
-- @return nil
function ang_methods:normalize ()
	self[1] = math_nAng( self[1] )
	self[2] = math_nAng( self[2] )
	self[3] = math_nAng( self[3] )
end

--- Return the Right Vector relative to the angle dir.
-- @return vector normalised.
function ang_methods:getRight ()
	return SF.WrapObject( unwrap( self ):Right() )
end

--- Return Rotated angle around the specified axis.
-- @param v Vector axis
-- @param deg Number of degrees or nil if radians.
-- @param rad Number of radians or nil if degrees.
-- @return The modified angle
function ang_methods:rotateAroundAxis ( v, deg, rad )
	SF.CheckType( v, SF.Types[ "Vector" ] )

	if rad then
		SF.CheckType( rad, "number" )
		deg = math.deg( rad )
	else
		SF.CheckType( deg, "number" )
	end

	local ret = Angle()

	ret:Set( unwrap( self ) )
	ret:RotateAroundAxis( SF.UnwrapObject( v ), deg )

	return wrap( ret )
end

--- Copies p,y,r from second angle to the first.
-- @param a Angle to copy from.
-- @return nil
function ang_methods:set ( a )
	SF.CheckType( a, ang_metamethods )

	self[1] = (a[1] or 0)
	self[2] = (a[2] or 0)
	self[3] = (a[3] or 0)
end

--- Return the Up Vector relative to the angle dir.
-- @return vector normalised.
function ang_methods:getUp ()
	return SF.WrapObject( unwrap( self ):Up() )
end

--- Sets p,y,r to 0. This is faster than doing it manually.
-- @return nil
function ang_methods:setZero ()
	self[1] = 0
	self[2] = 0
	self[3] = 0
end
