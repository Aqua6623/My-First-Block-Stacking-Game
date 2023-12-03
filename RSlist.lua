--[[
OO   OO O     O  O  OO
 XO OX  OXO OXO OXO XO OXOO
注意O与I的旋转中心。
]]
offset={
    Z={{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}},
    O={
    {0,1},{1,0},{0,-1},{-1,0},{1,0},{0,-1},{-1,0},{0,1}
    },
    I={
    {1,0},{0,-1},{-1,0},{0,1},{0,-1},{-1,0},{0,1},{1,0}
    }
}
offset.S=offset.Z offset.J=offset.Z offset.L=offset.Z offset.T=offset.Z

SRS={
    Z={
    --CW
    {{ 0, 0},{-1, 0},{-1, 1},{ 0,-2},{-1,-2}}, --0->R
    {{ 0, 0},{ 1, 0},{ 1,-1},{ 0, 2},{ 1, 2}}, --R->2
    {{ 0, 0},{ 1, 0},{ 1, 1},{ 0,-2},{ 1,-2}}, --2->L
    {{ 0, 0},{-1, 0},{-1,-1},{ 0, 2},{-1, 2}}, --L->0
    --CCW
    {{ 0, 0},{ 1, 0},{ 1, 1},{ 0,-2},{ 1,-2}}, --0->L
    {{ 0, 0},{ 1, 0},{ 1,-1},{ 0, 2},{ 1, 2}}, --R->0
    {{ 0, 0},{-1, 0},{-1, 1},{ 0,-2},{-1,-2}}, --2->R
    {{ 0, 0},{-1, 0},{-1,-1},{ 0, 2},{-1, 2}}  --L->2
    },
    O={
    {{0,0}},{{0,0}},{{0,0}},{{0,0}},{{0,0}},{{0,0}},{{0,0}},{{0,0}}
    },
    I={
    {{ 0, 0},{-2, 0},{ 1, 0},{-2,-1},{ 1, 2}},
    {{ 0, 0},{-1, 0},{ 2, 0},{-1, 2},{ 2,-1}},
    {{ 0, 0},{ 2, 0},{-1, 0},{ 2, 1},{-1,-2}},
    {{ 0, 0},{ 1, 0},{-2, 0},{ 1,-2},{-2, 1}},
    
    {{ 0, 0},{-1, 0},{ 2, 0},{-1, 2},{ 2,-1}},
    {{ 0, 0},{ 2, 0},{-1, 0},{ 2, 1},{-1,-2}},
    {{ 0, 0},{ 1, 0},{-2, 0},{ 1,-2},{-2, 1}},
    {{ 0, 0},{-2, 0},{ 1, 0},{-2,-1},{ 1, 2}}
    }
}
SRS.S=SRS.Z SRS.J=SRS.Z SRS.L=SRS.Z SRS.T=SRS.Z