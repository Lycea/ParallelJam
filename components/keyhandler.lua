 key_list ={
   
 }
 
 
 
 key_mapper={
   a = "left",
   d = "right",
   s = "down",
   e = "edit",
   r = "remove",
   n = "new",
   space = "space",
   escape = "exit",
   x = "dash",

   mt={
     __index=function(table,key) 
      return  "default"
     end
     
     }
   }
 
 setmetatable(key_mapper,key_mapper.mt)
 


key_list_game={
  down={speedup={0,1}},
  left={move={-1,0}},
  right={move={1,0}},
  space ={jump= true},
  exit = {exit = true},
  dash = {dash = true},
  edit = {editor = true},
  default={},
  mt={
     __index=function(table,key) 
      return  {}
     end
     
     }
}

key_list_edit={
    edit ={editor=true},
    left ={switch_type=-1},
    right={switch_type=1},
    down ={save=true},
    new  ={clear_world=true},
    dash ={invert=true},
    remove = {remove=true},
    
    mt={
     __index=function(table,key) 
      return  {}
     end
     
     }
}



key_list_dead={
    exit = {exit = true},
    mt={
     __index=function(table,key) 
      return  {}
     end
     
     }
}

setmetatable(key_list_dead,key_list_dead.mt)
setmetatable(key_list_game,key_list_game.mt)
setmetatable(key_list_edit,key_list_edit.mt)








function handle_keys(key)
    local state_caller_list ={
      [GameStates.PLAYING] = key_list_game,
      [GameStates.PAUSED] = key_list_dead,
      [GameStates.DEAD] = key_list_dead,
      [GameStates.LOAD_LEVEL] = key_list_dead,
      [GameStates.MENUE] = key_list_dead,
      [GameStates.EDIT] = key_list_edit
    }

     return state_caller_list[game_state][key_mapper[key]]
end


--------------------------------------------------------------------------------------
---- KEY HANDLE END MOUSE START
--------------------------------------------------------------------------------------




