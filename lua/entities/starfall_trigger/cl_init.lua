include("shared.lua")

language.Add("sboxlimit_starfall_trigger", "You've hit the Starfall Trigger limit!")
language.Add("undone_Starfall Trigger", "Undone Starfall Trigger")

function ENT:Initialize()
	self:UpdateCollisionBounds()
end

local col_red = Color(255, 0, 0, 255)

function ENT:Draw()
	--self:DrawModel()

	if self:GetSphereMode() then
		render.DrawWireframeSphere(self:GetPos(), self:GetSphereRadius(), 16, 16, col_red, true)
	else
		render.DrawWireframeBox(self:GetPos(), Angle(), self:GetBoxSize() / -2, self:GetBoxSize() / 2, col_red, true)
	end

	self:SetRenderBounds(self:GetCollisionBounds())
end