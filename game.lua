base_class = require("libs.classic.classic")
wf =require("libs.windfield")
require("components.creator")
require("globals.game_states")
require("components.keyhandler")
Timer = require("components.timer")
require("components.file_splorer")





local game ={}

gravity = 800
game_state = GameStates.EDIT


local jump_multi = 1


local move_timer = Timer(0.05)
local keylist = {}

player = nil


--option idx 
option_idx = 1

--save infos
save_name = "<default>"


local object_list={}


local object_types ={
  [1]="Solid",
  [2]="Mob",
  [3]="Door",
  [4]="Spike",
  [5]="Spawn",
  [6]="Collectible"
}


local object_type = 1

grid_size = 16



--mouse stuff
local mouse_x = 0
local mouse_y = 0

local first_x = 0
local first_y = 0


local last_click = false

local select_timer = Timer(0.3)

local selected_item = nil
local delete_timer = Timer(0.1)

local invert_timer = Timer(0.1)
local exit_timer   = Timer(0.1)





local function gen_object(obj_type,x,y,w,h)
    
    local object = world:newRectangleCollider(x, y,w, h)
    print(obj_type)
    object:setCollisionClass(obj_type)
    object:setFixedRotation(true)
    
    if obj_type ~= "Mob" then
        object:setType("static")
    end
    
    return object
end



function game.load()
   world = creator.sample_world()
   allow_jump = true 
end





function game.update(dt)
    local speed = 800
    local jump_speed = 400
    local down_speed = 5
    
    
    for key,_ in pairs(keylist) do
        local action =handle_keys(key)
        
        if game_state == GameStates.PLAYING then
            if action["move"] and move_timer:is_done()==true then
                player:applyForce( action["move"][1]*speed*gravity, 0) 
                move_timer:update()
            elseif action["speedup"] then
                player:applyForce( 0, action["speedup"][2]*down_speed*gravity) 
            elseif action["dash"] then
                
            elseif action["editor"] then
                game_state = GameStates.EDIT
                
                --remove player object
                player:destroy()
                player = nil
                
            elseif action["jump"] and allow_jump then
                player:applyForce(0, -jump_speed*gravity)
                allow_jump = false
            end
            
        elseif game_state == GameStates.LOAD_LEVEL then
            if action["editor"] then
                game_state = GameStates.EDIT
            elseif action["switch_file"] and select_timer:is_done()==true then
                select_timer:update()
                splorer.idx_change(action["switch_file"])
            elseif action["load_level"] then
                debuger.on()
                local lvl_name = splorer.get_selected()
                print("Loading lvl...",lvl_name)
                
                save_name = string.gsub(lvl_name,"[.]txt","")
                
                local chunk =love.filesystem.load(lvl_name)
                local level_data = chunk()
                
                creator.deleteWorld(world)
                object_list = nil
                object_list = {}
                
                world = creator.newWorld()
                
                
                for id, obj in pairs(level_data) do
                    print(obj[1])
                    local rec ={x=obj.x,y=obj.y,w=obj.w,h=obj.h}
                            table.insert(object_list,{obj[1],rec,
                                            gen_object(obj[1],
                                            rec.x,rec.y,
                                            rec.w,rec.h
                                                      )
                                                     }
                                        )
                end
                
                
                debuger.off()
            end

        elseif game_state == GameStates.EDIT or game_state == GameStates.TXT_INPUT then

            if action["editor"] then
                game_state = GameStates.PLAYING
                
                player = creator.player(world,50,50)

            elseif action["remove_key"] and select_timer:is_done()then
                save_name = string.sub(save_name,0,math.max(0,#save_name-1))
                select_timer:update()
            elseif action["option_idx"] and select_timer:is_done() then
                option_idx=option_idx+ action["option_idx"]
                if option_idx >2 then option_idx = 1 end
                if option_idx<1 then option_idx = 2 end
                states_ = {[1]=GameStates.EDIT, [2]=GameStates.TXT_INPUT}
                game_state = states_[option_idx]
                select_timer:update()
            elseif action["switch_type"] and select_timer:is_done() then
            
            
                object_type = object_type + action["switch_type"]
                if object_type > #object_types then
                   object_type = 1
                elseif object_type == 0 then
                    object_type = #object_types
                end
                select_timer:update()
            elseif action["load"] then
                print("opening loading menue...")
                game_state = GameStates.LOAD_LEVEL
                splorer.get_files()
            elseif action["save"] then

                local file = save_name == "<default>" and io.open(os.time().."testlevel.txt","w") or io.open(save_name..".txt","w")
                

                if not file then
                    print("Not able to save file :(")
                    return
                end

                file:write("local data ={\n")
                for _,data in pairs(object_list) do
                    file:write("{"..'"'..data[1]..'"'..","
                                  .."x ="..data[2].x..","
                                  .."y ="..data[2].y..","
                                  .."w ="..data[2].w..","
                                  .."h ="..data[2].h..","
                                  .."},\n")
                    
                end
                
                file:write("\n}\nreturn data")
                io.close(file)
                
            elseif action["clear_world"] then
                creator.deleteWorld(world)
                object_list = nil
                object_list = {}
                
                world = creator.newWorld()
                save_name="<default>"
            elseif action["invert"] and invert_timer:is_done() then
                gravity = gravity*-1
                print(gravity)
                world:setGravity(0,gravity)
                invert_timer:update()
            elseif action["remove"] and selected_item then
                object_list[selected_item][3]:destroy()
                object_list[selected_item] = nil
                selected_item = nil
            end
        end
    
    end
        
    
    if game_state == GameStates.PLAYING then
        world:update(dt)
        local x,y = player:getLinearVelocity()
        player:setLinearVelocity(x-(x/20),y)
        if player:enter("Door") then
            player:applyLinearImpulse(1000, 0)
        end
        if player:enter("Solid") then
            allow_jump = true
            x,y=player:getLinearVelocity()
            player:setLinearVelocity(x,0)
        end
        if player:enter("Spike") then
            allow_jump = false
           player:destroy()
           player = creator.player(world,50,50)
        end
    end
end



local function get_grided(x,y)
    local x_pos =math.floor(x/grid_size)*grid_size
    local y_pos =math.floor(y/grid_size)*grid_size
    
    return x_pos,y_pos
end



local function draw_objects()
    local num = 0
    local function stencil()
        
        
       for i=-300, love.graphics.getWidth()+300, 10  do
         love.graphics.line(i,0,i+(num%3)*200,love.graphics.getHeight())
       end
       
    end
    
    
    for idx,obj_ in pairs(object_list) do
        num = idx
        if obj_[1]=="Spike" then
            
            love.graphics.setColor(1,0,0)
        else
            love.graphics.setColor(1,1,1)
        end
        
        --love.graphics.stencil(stencil,"replace",1)
        --love.graphics.setStencilTest("greater", 0)
        
        --love.graphics.rectangle("fill", obj_[2].x,obj_[2].y,obj_[2].w,obj_[2].h) 
        --love.graphics.setStencilTest()
        
        love.graphics.rectangle("line", obj_[2].x,obj_[2].y,obj_[2].w,obj_[2].h) 
        
		love.graphics.setColor(1,1,1)
    end
     
    
    
    if player then
        x = player:getX()
        y = player:getY()
        love.graphics.rectangle("fill",x-(grid_size),y-(grid_size*1.5),grid_size*2,grid_size*3)
    end
    
   
end



local scale = 1
function game.draw()
    love.graphics.scale(scale,scale)
    --world:draw()
    
    draw_objects()

    
    
    if game_state == GameStates.EDIT or game_state == GameStates.LOAD_LEVEL or game_state == GameStates.TXT_INPUT then
        love.graphics.print("Block type: "..object_types[object_type],20,30)
        love.graphics.print("Save name: "..save_name,20,40)

        love.graphics.rectangle("line",5,option_idx *10 +20 +5,5,5)
        
         if selected_item then
          local rect=object_list[selected_item][2]
          
          love.graphics.setColor(0,1,0)
          love.graphics.rectangle("line",rect.x,rect.y,rect.w,rect.h)
          love.graphics.setColor(1,1,1)
          return
        end
    
    
    
        if last_click == false then
            local x_pos,y_pos = get_grided(mouse_x,mouse_y)
            love.graphics.rectangle("line",x_pos/scale,y_pos/scale,grid_size,grid_size)
        else
            local x_pos,y_pos = get_grided((mouse_x/scale - first_x/scale+grid_size),(mouse_y/scale-first_y/scale+grid_size))
            love.graphics.rectangle("line",first_x/scale,first_y/scale,x_pos,y_pos)
        end
    end
    
   
   
   if game_state == GameStates.LOAD_LEVEL then
       splorer.draw()
   end
   
    love.graphics.scale(scale,scale)
    
    
    
    
end

function game.keyHandle(k,s,r,pressed)
    
    
    if pressed == true then
        keylist[k] = true
    else
        keylist[k] = nil
    end
    
    print(k,s,r)
    
end






function game.mousepress(x,y)
    
    if game_state ~= GameStates.EDIT then
        return
    end
    
    
    if selected_item then
        return
    end
    
    
    -- if it is not set use as first point
    if last_click == false then
        first_x,first_y =get_grided(x,y)
        last_click = true
    else
        local last_x,last_y = get_grided(x+grid_size,y+grid_size)
        
        
        debuger.on()

            
        
        if last_y == first_y or last_x == first_x then
            last_click = false
            return
        end
        
        
        first_x_ = math.min(last_x,first_x)
        first_y_ = math.min(last_y,first_y)
        
        last_x_ = math.max(last_x,first_x)
        last_y_ = math.max(last_y,first_y)
        
        
        first_x = first_x_
        first_y = first_y_
        
        last_x = last_x_
        last_y = last_y_
        
        local rec ={
                    x = first_x,
                    y = first_y,
                    w = last_x-first_x,
                    h = last_y-first_y
            }
 
        
        table.insert(object_list,{object_types[object_type],rec,
                     gen_object(object_types[object_type],
                                rec.x/scale,rec.y/scale,
                                rec.w/scale,rec.h/scale
                               )
                            }
                    )
        debuger.off()
        last_click = false
    end
    
end

local function in_object(x,y,obj)
    if x >= obj.x and
       x <= obj.x + obj.w and
       y >= obj.y and
       y <= obj.y +obj.h then
      
      return true
   end
   
end




function game.mousemove(x,y,dx,dy)
  mouse_x = x
  mouse_y = y
  debuger.on()
  
  
  for key,object in pairs(object_list) do
    if in_object(x,y,object[2]) == true then
       selected_item = key
       return
    end
  end
  
  debuger.off()
  selected_item = nil
end



function game.text(txt)
    if game_state == GameStates.TXT_INPUT then
        save_name=save_name..txt
    end

end

return game