local Class = require "libs.hump.class"
local imgParticle = love.graphics.newImage("graphics/particles/11.png")
local DeathParticles = Class{}

function DeathParticles:init()
    self.particleSystem = love.graphics.newParticleSystem(imgParticle,100) 
                                                      -- image, #particles
    self.particleSystem:setParticleLifetime(0.0, 1.0) -- 0 to 2.0 secs
    self.particleSystem:setEmissionRate(0) -- No continuous emission
    self.particleSystem:setSizes(0.2, 0) -- Start tiny, shrink to 0
    self.particleSystem:setSpeed(10, 20) -- Random speed range
    self.particleSystem:setLinearAcceleration(0, 0, 0, 0) -- No gravity
    self.particleSystem:setEmissionArea("uniform",20,20,0,true)
    self.particleSystem:setColors(1, 0, 0, 1, 0, 0, 0, 0) 
    -- Red fading to transparent(r, g, b, a, r, g, b, a)    
end

function DeathParticles:setColor(r,g,b) -- sets the particle color
    self.particleSystem:setColors(r,g,b,1,r,g,b,0)
end

function DeathParticles:trigger(x,y)
    if x and y then -- if x & y not nil, set then now
        self.particleSystem:setPosition(x+20, y+20)
    end
    self.particleSystem:emit(4) -- Emit 1 particles
end

function DeathParticles:update(dt)
    self.particleSystem:update(dt)
end

function DeathParticles:draw(x,y)
    -- if x & y are nil, it will use the trigger x,y 
    love.graphics.draw(self.particleSystem, x, y)
end

function DeathParticles:isActive() 
    -- returns true if the particles are still running
    return self.particleSystem:getCount() > 0
end

-- Always remember to return the class at the end of the file
return DeathParticles 
