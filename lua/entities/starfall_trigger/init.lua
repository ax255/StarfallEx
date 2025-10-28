AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

CreateConVar("sbox_maxstarfall_trigger", 20, { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE })

function ENT:Initialize()
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)

	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:SetTrigger(true)

	self:DrawShadow(false)

	self.inside_entities = {}
	self.inside_sphere_entities = {}
end

local ent_meta = FindMetaTable("Entity")
local vec_meta = FindMetaTable("Vector")

function ENT:SphereModeTouch()
	local self_tbl = self:GetTable()
	local trigger_pos = ent_meta.GetPos(self)

	for i, ent in pairs(self_tbl.inside_entities) do
		if not ent:IsValid() then continue end

		if self_tbl.SphereRadiusSqr > vec_meta.DistToSqr(trigger_pos, ent_meta.GetPos(ent)) then
			if not self_tbl.inside_sphere_entities[i] then
				self_tbl.inside_sphere_entities[i] = ent

				if self_tbl.sf_starttouch then
					self_tbl.sf_starttouch(ent)
				end
			end
		elseif self_tbl.inside_sphere_entities[i] then
			self_tbl.inside_sphere_entities[i] = nil

			if self_tbl.sf_endtouch then
				self_tbl.sf_endtouch(ent)
			end
		end
	end
end

local next_think_interval = (engine.TickInterval() / 16) * 100

function ENT:Think()
	if self.SphereMode then
		if self.sf_instance then
			local start_time = SysTime()
			self:SphereModeTouch()
			self.sf_instance.cpu_total = self.sf_instance.cpu_total + (SysTime() - start_time)
		else
			self:SphereModeTouch()
		end

		self:NextThink(CurTime() + next_think_interval)

		return true
	end
end

function ENT:StartTouch(ent)
	self.inside_entities[ent:EntIndex()] = ent

	if not self.SphereMode and self.sf_starttouch then
		self.sf_starttouch(ent)
	end
end

function ENT:EndTouch(ent)
	local ent_index = ent:EntIndex()
	self.inside_entities[ent_index] = nil

	if self.SphereMode and self.sf_endtouch and self.inside_sphere_entities[ent_index] then
		self.inside_sphere_entities[ent_index] = nil
		self.sf_endtouch(ent)
	end

	if not self.SphereMode and self.sf_endtouch then
		self.sf_endtouch(ent)
	end
end

local function createTrigger(instance, pos)
	local trigger = ents.Create("starfall_trigger")
	trigger:Spawn()
	trigger:SetPos(pos)
	trigger.sf_instance = instance

	return trigger
end

SF.createTrigger = createTrigger