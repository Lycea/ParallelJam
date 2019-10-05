local game = require("game")


function love.load()
    love.keyboard.setKeyRepeat(true)
    debuger = require("mobdebug")
    --debuger.start()
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
