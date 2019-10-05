base_class = require("libs.classic.classic")
wf =require("libs.windfield")
require("components.creator")
require("globals.game_states")
require("components.keyhandler")
Timer = require("components.timer")

local game ={}

gravity = 512
game_state = GameStates.PLAYING

local move_timer = Timer(0.05)
local keylist = {}

function game.load()
   world,box = creator.sample_world()
   allow_jump = true
   
end





function game.update(dt)
    local speed = 800
    local jump_speed = 800
    local down_speed = 5
    
    debuger.on()
    for key,_ in pairs(keylist) do
        local action =handle_keys(key)
        
        
        if action["move"] and move_timer:is_done()==true then
            box:applyForce( action["move"][1]*speed*gravity, 0) 
            move_timer:update()
        elseif action["speedup"] then
            box:applyForce( 0, action["speedup"][2]*down_speed*gravity) 
        elseif action["dash"] then
            
        elseif action["jump"] and allow_jump then
            box:applyForce(0, -jump_speed*gravity)
            allow_jump = false
        end
    
    end
    
    debuger.off()
    
    
    
    world:update(dt)
    local x,y = box:getLinearVelocity()
    box:setLinearVelocity(x-(x/20),y)
    if box:enter("Door") then
        box:applyLinearImpulse(1000, 0)
    end
    if box:enter("Solid") then
        allow_jump = true
        x,y=box:getLinearVelocity()
        box:setLinearVelocity(x,0)
    end
end


function game.draw()
    world:draw()
end

function game.keyHandle(k,s,r,pressed)
    
    
    if pressed == true then
        keylist[k] = true
    else
        keylist[k] = nil
    end
    
    
end
return game