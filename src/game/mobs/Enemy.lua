local Class = require "libs.hump.class"
local Hbox = require "src.game.Hbox"
local Tween = require "libs.tween"
local DeathParticles = require "src.game.mobs.DeathParticles"

local Enemy = Class{}
function Enemy:init()
    self.x = 0
    self.y = 0
    self.name = ""
    self.type = ""
    self.dir = "l" -- Direction r = right, l = left
    self.state = "idle" -- idle state
    self.invincible = false 
    self.animations = {} -- dict of animations (each mob will have its own)
    self.sprites = {} -- dict of sprites (for animations)
    -- Attributes
    self.hitboxes = nil -- for later
    self.hurtboxes = nil -- for later
    self.hp = 10 -- hit/health points 
    self.damage = 10 -- mob's damage
    self.tweenDamage = nil -- Tween when mob is hit
    self.damageDone = 0 -- damage done to mob
    self.damageY = 0 -- y position of damage display
    self.died = false
    self.score = 100 -- score to kill this mob 
    self.deathParticles = DeathParticles()
end

function Enemy:getDimensions() -- returns current Width,Height
    return self.animations[self.state]:getDimensions()
end

function Enemy:setAnimation(st,sprite,anim)
    self.animations[st] = anim
    self.sprites[st] = sprite
end

function Enemy:setCoord(x,y)
    self.x = x
    self.y = y
end

function Enemy:update(dt)
    self.animations[self.state]:update(dt)

    if self.tweenDamage then -- Mob was hit, so tween
        self.tweenDamage:update(dt)
    end

    if self.deathParticles:isActive() then -- Update death particles if there are any
        self.deathParticles:update(dt)
    end
end

function Enemy:draw()
    self.animations[self.state]:draw(self.sprites[self.state],
        math.floor(self.x), math.floor(self.y))
    
    if self.tweenDamage then -- Print the damage done to mob with tween
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(self.damageDone, self.x, self.damageY)
        love.graphics.setColor(1, 1, 1)
    end

    if self.died then -- Draw death particles when mob dies
        self.deathParticles:draw()
    end

    if debugFlag then
        local w,h = self:getDimensions()
        love.graphics.rectangle("line",self.x,self.y,w,h) -- sprite
    
        if self:getHurtbox() then
            love.graphics.setColor(0,0,1) -- blue
            self:getHurtbox():draw()
        end
    
        if self:getHitbox() then
            love.graphics.setColor(1,0,0) -- red
            self:getHitbox():draw()
        end
        love.graphics.setColor(1,1,1) 
    end
        
end

function Enemy:changeDirection()
    if self.dir == "l" then
        self.dir = "r"
    else
        self.dir = "l"
    end

    for st,anim in pairs(self.animations) do
        anim:flipH()
    end
end

function Enemy:hit(damage)
    self.hp = self.hp - damage

    if self.hp <= 0 then -- Mob died, trigger death particles
        self.died = true
        self.deathParticles:trigger(self.x, self.y)
    end

    self.damageDone = damage -- Store damage done to mob for printing

    self.damageY = self.y -- Set damage value's location to mob's location
    self.tweenDamage = Tween.new(1, self, {damageY = self.y - 15}) -- make the damage number rise vertically
end

function Enemy:getHbox(boxtype)
    if boxtype == "hit" then
        return self.hitboxes[self.state]
    else
        return self.hurtboxes[self.state]
    end
end

function Enemy:getHitbox()
    return self:getHbox("hit")
end

function Enemy:getHurtbox()
    return self:getHbox("hurt")
end

function Enemy:setHurtbox(state,ofx,ofy,width,height)
    self.hurtboxes[state] = Hbox(self,ofx,ofy,width,height)
end

function Enemy:setHitbox(state,ofx,ofy,width,height)
    self.hitboxes[state] = Hbox(self,ofx,ofy,width,height)
end


return Enemy