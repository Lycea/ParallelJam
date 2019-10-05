


local Timer = base_class:extend()

function Timer:new(check_time)
   self.last_time = 0
   self.time_out = check_time or 0.1
end

function Timer:update(time)
    self.last_time = time or love.timer.getTime()
end

function Timer:is_done(time)
   state= self.last_time+self.time_out  <= (time or love.timer.getTime() )
   return state
end


return Timer