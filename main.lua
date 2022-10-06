local game = require("game")


function love.load()
    love.keyboard.setKeyRepeat(true)
    --debuger = require("mobdebug")
    debuger = {
        start = function ()end,
        stop = function ()end,
        on = function ()end,
        off = function () end
    }
    debuger.start()
    game.load()
end

function love.draw()
    game.draw()
end

function love.update(dt)
    game.update(dt)
end

function love.keypressed(k,s,r)
  game.keyHandle(k,s,r,true)
  if key == "escape" then
    love.event.quit()
  end

end

function love.keyreleased(k)
    game.keyHandle(k,0,0,false)
end


function love.mousepressed(x,y,btn,t)
    if btn == 1 then
       game.mousepress(x,y) 
    end
end

function love.mousemoved(x,y,dx,dy)
    game.mousemove(x,y,dx,dy)
end

function love.textinput(txt)
    game.text(txt)
end

