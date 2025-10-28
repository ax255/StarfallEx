ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName       = "Starfall Trigger"
ENT.Author          = "Ax25"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false
ENT.DoNotDuplicate = true
ENT.DisableDuplicator = true
ENT.PhysgunDisabled = true

ENT.IsSFTrigger = true

ENT.BoxSize = Vector(0, 0, 0)
ENT.SphereRadius = 0
ENT.SphereRadiusSqr = ENT.SphereRadius ^ 2
ENT.SphereMode = false

cleanup.Register("starfall_trigger")

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "SphereMode")
	self:NetworkVar("Vector", 0, "BoxSize")
	self:NetworkVar("Float", 0, "SphereRadius")

	self:NetworkVarNotify("BoxSize", function(_, _, old, new)
		self.BoxSize = new
		self:UpdateCollisionBounds()
	end)

	self:NetworkVarNotify("SphereRadius", function(_, _, old, new)
		self.SphereRadius = new
		self.SphereRadiusSqr = self.SphereRadius ^ 2
		self:UpdateCollisionBounds()
	end)

	self:NetworkVarNotify("SphereMode", function(_, _, old, new)
		self.SphereMode = new
		self:UpdateCollisionBounds()
	end)
end

function ENT:UpdateCollisionBounds()
	if self.SphereMode then
		local radius = self.SphereRadius
		local size = Vector(radius * 2, radius * 2, radius * 2)
		self.trigger_mins, self.trigger_maxs = size / -2, size / 2

		self:SetCollisionBounds(Vector(-radius, -radius, -radius), Vector(radius, radius, radius))
	else
		local size = self.BoxSize
		self.trigger_mins, self.trigger_maxs = size / -2, size / 2

		self:SetCollisionBounds(self.trigger_mins, self.trigger_maxs)
	end
end