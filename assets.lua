local gc=love.graphics

blocks={
    Z={{0,0},{1,0},{-1,1},{0,1}},
    S={{0,0},{-1,0},{1,1},{0,1}},
    J={{0,0},{-1,0},{1,0},{-1,1}},
    L={{0,0},{-1,0},{1,0},{1,1}},
    T={{0,0},{-1,0},{1,0},{0,1}},
    O={{.5,.5},{.5,-.5},{-.5,.5},{-.5,-.5}},
    I={{-1.5,.5},{-.5,.5},{.5,.5},{1.5,.5}},
}
spawnpos={
    Z={5,21},S={5,21},J={5,21},L={5,21},T={5,21},O={5.5,21.5},I={5.5,20.5},
}
color={
    Z={1,.08,.08},
    S={0,1,0},
    J={0,.64,1},
    L={1,.44,.05},
    T={.75,0,1},
    O={1,1,0},
    I={0,1,.6},

    g1={.5,.5,.5},
    g2={.75,.75,.75},
    g_ls={1,1,.5},

    ls={1,1,.75}
}
noffset={--Next和Hold的显示偏移
    Z={.5,0},S={.5,0},J={.5,0},L={.5,0},T={.5,0},O={.5,.5},I={.5,0}
}
texture={
    Z=gc.newImage('texture/red.bmp'),
    S=gc.newImage('texture/lime.bmp'),
    J=gc.newImage('texture/sky.bmp'),
    L=gc.newImage('texture/orange.bmp'),
    T=gc.newImage('texture/violet.bmp'),
    O=gc.newImage('texture/yellow.bmp'),
    I=gc.newImage('texture/aqua.bmp'),
    g_ls=gc.newImage('texture/g_loosen.bmp'),
    ls=gc.newImage('texture/loosen.bmp'),
    ghost=gc.newImage('texture/gray.bmp'),
    ox=10,oy=10
}