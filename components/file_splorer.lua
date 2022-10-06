splorer ={}



local files = {}
splorer.shown_files =4
splorer.idx = 1
local font = love.graphics.getFont()
local size = font:getHeight()

function splorer.get_files()
   files ={}
    
   debuger.on()
   local items = love.filesystem.getDirectoryItems("")
   for id,item in pairs(items) do
    local info = love.filesystem.getInfo(item,"file")
    
    if info then
        local ending = item:sub(item:find("%.")or 0,item:len())
        
        if ending == ".txt" then
            table.insert(files,item)
            print(item)
        end
    end
   end
   print(#items,#files)
   debuger.off()
end



function splorer.idx_change(num)
 splorer.idx = math.max(1, math.min(splorer.idx+num,#files))   
 print(splorer.idx)
end


function splorer.get_selected()
    return files[splorer.idx]
end


function splorer.draw()

    --for id,item in pairs(files) do
    --    love.graphics.print(id.." "..item, 20,id*(size+10))
    --end
    love.graphics.push()
    
    love.graphics.translate(0,size*10)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill",0,-(size*2) -10,220,(size+10)*#files)
    
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line",0,-(size*2) -10,220,(size+10)*(splorer.shown_files+2))
    
    
    for id = math.max(splorer.idx-2,1),math.min(splorer.idx-2 +splorer.shown_files,#files) do
        
        if id == splorer.idx then
            love.graphics.rectangle("line",10, (id-splorer.idx+1) *(size+10)-5,190,size+10)
        end
        love.graphics.print(id.." "..files[id], 20,(id-splorer.idx+1)*(size+10))
    end
    love.graphics.pop()
end
