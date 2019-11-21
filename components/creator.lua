

creator={}




function creator.newWorld()
    local _world = wf.newWorld(0, 0, true)
    
    _world:setGravity(0, gravity)
    _world:addCollisionClass("Solid")
    _world:addCollisionClass("Mob") --player 
    _world:addCollisionClass("Door",{ignores={"Mob"}})
    
    _world:addCollisionClass("Spike")
    _world:addCollisionClass("Spawn",{ignores={"Mob"}})
    
    

    
    
   -- local wall_left = _world:newRectangleCollider(0, 0, 50, 600)
    --local wall_right = _world:newRectangleCollider(750, 0, 50, 600)
    --local ground = _world:newRectangleCollider(0, 550, 800, 50)
    
    
    --ground:setType('static') -- Types can be 'static', 'dynamic' or 'kinematic'. Defaults to 'dynamic'
    --ground:setCollisionClass("Solid")
    --wall_left:setType('static')
    --wall_left:setCollisionClass('Solid')

    --wall_right:setType('static')
    --wall_right:setCollisionClass('Solid')
    
    --local test_door = _world:newRectangleCollider(50, 50, 50, 50)
    --test_door:setCollisionClass('Door')
    
    
    return _world
end


function creator.objects_from_list(obj_list)

end


function creator.player(world,x,y)
    
    local box= world:newRectangleCollider(x or 200,y or 0,grid_size*2,grid_size*3)
    box:setRestitution(0)
    box:setLinearDamping(0)
    box:setFixedRotation(true)
    box:setCollisionClass('Mob')
    box:setMass(box:getMass()*0.75 )
    
    
    return box
end

function creator.deleteWorld(world)
    world:destroy()
end

function creator.sample_world()
    local wld= creator.newWorld()
    
    
    return wld
end
