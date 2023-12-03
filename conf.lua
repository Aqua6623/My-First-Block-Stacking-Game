function love.conf(t)
    local W=t.window
    W.title="测试木琴"
    W.borderless=false
    W.resizable=true
    W.minwidth=640
    W.minheight=480

    W.msaa=8
    W.vsync=0
end