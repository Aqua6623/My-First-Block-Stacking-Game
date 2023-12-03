mainLoop=love.run()
require("function")
require("assets")
require("RSlist")
math.randomseed(os.time())

gc=love.graphics
fs=love.filesystem
function love.load()
    height=gc.getHeight()
    width=gc.getWidth()
    Exo_2=gc.newFont('Exo2.otf',128)
end
function love.resize(w,h)
    height=h
    width=w
end

keyset={
    left={'left','l','kp1'},right={'right','\'','kp3'},
    CW={'y','up','p','kp5'},CCW={'t','x'},flip={},
    SD={'down',';','kp2'},HD={'space','c'},hold={'z','lshift','rshift','0'}
}
leftban=false rightban=false

bag={'Z','S','J','L','T','O','I'}
next={}
current='' hold='' canhold=true
curpiece={} holdpiece={} lastkey=''

DAS_move=0.11 ARR=0 Ldas,Rdas=0,0 Larr,Rarr=ARR,ARR SDtime=0 SDarr=SDtime
preview=6

posx,posy=0,0 ori=0
falltime,landtime=0,0 fallARR=5 lockdelay=30 re_chance,recini=9999,9999

newLine=summonline(' ',10)
field=summonfield(newLine,50)

loosen={} spincount=0

function lock_ini()
    lock(curpiece,current,posx,posy,field)
    while #loosen~=0 do loosen_fall(loosen,field,'g_ls') end
    line_clear(field)
    current=table.remove(next,1) canhold=true ori=0
    if landtime>=lockdelay then falltime=landtime-lockdelay else falltime=0 end
    landtime=0
    curpiece=copy(blocks[current]) posx,posy=spawnpos[current][1],spawnpos[current][2]
    Larr,Rarr,SDarr=ARR,ARR,SDtime re_chance=recini spincount=0
    if coincide(field,loosen,posx,posy,curpiece) then RESET() end
end
function RESET()
    hold='' canhold=true
    current,next='',{}
    local s=shuffle(bag)
    for h=1,#s do table.insert(next,s[h]) end
    current=table.remove(next,1) curpiece=copy(blocks[current])
    field=summonfield(newLine,50)
    loosen={} spincount=0 falltime,landtime=0,0
    posx,posy=spawnpos[current][1],spawnpos[current][2] ori=0 re_chance=recini
end

do
    local s=shuffle(bag)
    for h=1,#s do table.insert(next,s[h]) end
    current=table.remove(next,1) curpiece=copy(blocks[current])
    posx,posy=spawnpos[current][1],spawnpos[current][2]
end
function love.keypressed(k)
    local landed=coincide(field,loosen,posx,posy-1,curpiece)
    lastkey=k
    if k=='escape' then love.event.quit() end

    if k=='r' then RESET() end
    
    if include(k,keyset.left) and not leftban and not coincide(field,loosen,posx-1,posy,curpiece) then 
        if landed and re_chance>0 then landtime=0 re_chance=re_chance-1 end
        posx=posx-1
    elseif include(k,keyset.right) and not rightban and not coincide(field,loosen,posx+1,posy,curpiece) then 
        if landed and re_chance>0 then landtime=0 re_chance=re_chance-1 end
        posx=posx+1
    elseif include(k,keyset.CW) then curpiece,ori,posx,posy,success=kick(curpiece,ori,'R',current,posx,posy,field,loosen,SRS)
        if landed and re_chance>0 and success then landtime=0 re_chance=re_chance-1 end
    elseif include(k,keyset.CCW) then curpiece,ori,posx,posy,success=kick(curpiece,ori,'L',current,posx,posy,field,loosen,SRS)
        if landed and re_chance>0 and success then landtime=0 re_chance=re_chance-1 end
    elseif include(k,keyset.HD) then
        while not coincide(field,loosen,posx,posy-1,curpiece) do posy=posy-1 end
        lock_ini()
    elseif include(k,keyset.SD) then
        if SDtime==0 then
            while not coincide(field,loosen,posx,posy-1,curpiece)
            do posy=posy-1 end
        elseif not landed then posy=posy-1 end
    elseif include(k,keyset.hold) and canhold then 
        hold,current=current,hold
        canhold=false ori=0 falltime=0
        if current=='' then
            current=table.remove(next,1)
        end
        curpiece=copy(blocks[current]) posx,posy=spawnpos[current][1],spawnpos[current][2]
        if landed and re_chance>0 then landtime=0 end
    end
    
    --O 旋 盾 构 机
    if current=='O' then 
        local reset=true
        if not rightban and love.keyboard.isDown(keyset.right) and coincide(field,loosen,posx+1,posy,curpiece) then
            if include(k,keyset.CW) or include(k,keyset.CCW) then reset=false
            spincount=spincount+1
            check_loose_move(curpiece,posx,posy,'R',field,loosen,spincount)
            end
        end
        if not leftban and love.keyboard.isDown(keyset.left) and coincide(field,loosen,posx-1,posy,curpiece) then
            if include(k,keyset.CW) or include(k,keyset.CCW) then reset=false
            spincount=spincount+1
            check_loose_move(curpiece,posx,posy,'L',field,loosen,spincount)
            end
        end
        if love.keyboard.isDown(keyset.SD) and coincide(field,loosen,posx,posy-1,curpiece) then
            if include(k,keyset.CW) or include(k,keyset.CCW) then reset=false
            spincount=spincount+1
            check_loose_move(curpiece,posx,posy,'D',field,loosen,spincount)
            end
        end
        if reset then spincount=0 end
    end
end
function love.update(dt)
    falltime=falltime+dt
    if not coincide(field,loosen,posx,posy-1,curpiece) then 
        while falltime>=fallARR and not coincide(field,loosen,posx,posy-1,curpiece) do
            posy=posy-1 falltime=falltime-fallARR
        end
    else
        falltime=0 landtime=landtime+dt
        if landtime>=lockdelay then lock_ini() end
    end
    if #next<21 then
        local s=shuffle(bag)
        for h=1,#s do
            table.insert(next,s[h])
        end
    end
    gposx,gposy=getghostpos(field,loosen,posx,posy,curpiece)
    --和DAS ARR相关的操作
    if not leftban then
    if love.keyboard.isDown(keyset.left) then
        rightban=true
        if Ldas>=DAS_move then Larr=Larr+dt+Ldas-DAS_move Ldas=DAS_move
            while Larr>=ARR and not coincide(field,loosen,posx-1,posy,curpiece) do
                if coincide(field,loosen,posx,posy-1,curpiece) and re_chance>0
                then landtime=0 re_chance=re_chance-1 end
                posx=posx-1 Larr=Larr-ARR
                while falltime>=fallARR and not coincide(field,loosen,posx,posy-1,curpiece) do
                    posy=posy-1 falltime=falltime-fallARR
                end
            end
        else Ldas=Ldas+dt end
    else rightban=false Ldas,Larr=0,ARR end
    end
    if not rightban then
    if love.keyboard.isDown(keyset.right) then
        leftban=true
        if Rdas>=DAS_move then Rarr=Rarr+dt+Rdas-DAS_move Rdas=DAS_move
            while Rarr>=ARR and not coincide(field,loosen,posx+1,posy,curpiece) do
                if coincide(field,loosen,posx,posy-1,curpiece) and re_chance>0
                then landtime=0 re_chance=re_chance-1 end
                posx=posx+1 Rarr=Rarr-ARR
                while falltime>=fallARR and not coincide(field,loosen,posx,posy-1,curpiece) do
                    posy=posy-1 falltime=falltime-fallARR
                end
            end
        else Rdas=Rdas+dt end
    else leftban=false Rdas,Rarr=0,ARR end
    end
    if love.keyboard.isDown(keyset.SD) then SDarr=SDarr+dt
        while SDarr>=SDtime and not coincide(field,loosen,posx,posy-1,curpiece) do posy=posy-1 SDarr=SDarr-SDtime end
    else SDarr=0 end
end
function love.draw()
    gc.setColor(1,1,1,0.5)
    gc.print("Field height:"..#field,Exo_2,60,height-64,0,0.25,0.25)
    gc.print("Rotate count:"..spincount,Exo_2,60,height-100,0,0.25,0.25)

    gc.setColor(color[current])
    gc.print(current,Exo_2,60,100,0,0.25,0.25)
    gc.print(""..posx..", "..posy,Exo_2,60,125,0,0.5,0.5)
    gc.print(""..ori,Exo_2,60,180,0,0.5,0.5)

    gc.setColor(1,1,1)
    for y=1,#field do for x=1,#field[1] do
        if field[y][x]~=' ' then
            gc.draw(texture[field[y][x]],width/2+20*(x-5.5),height/2-20*(y-10.5),0,1,1,picO(texture[field[y][x]]))
        end
    end end
    for i=1,#curpiece do
        gc.setColor(1,1,1,.5)--落点提示
        gc.draw(texture['ghost'],width/2+20*(curpiece[i][1]+gposx-5.5),height/2-20*(curpiece[i][2]+gposy-10.5),0,1,1,picO(texture['ghost']))
    end
    gc.setColor(1,1,1)
    for i=1,#curpiece do
        gc.draw(texture[current],width/2+20*(curpiece[i][1]+posx-5.5),height/2-20*(curpiece[i][2]+posy-10.5),0,1,1,picO(texture[current]))
    end
    for i=1,#loosen do
        gc.draw(texture['ls'],width/2+20*(loosen[i][1]-5.5),height/2-20*(loosen[i][2]-10.5),0,1,1,picO(texture['ls']))
    end
    if hold~='' then
        gc.print(hold,Exo_2,100,100,0,0.25,0.25)
        local holdp=blocks[hold]
        for J=1,#holdp do
            local x=-#field[1]/2-3+noffset[hold][1]+holdp[J][1]
            local y=8+noffset[hold][2]+holdp[J][2]
            gc.draw(texture[hold],width/2+20*x,height/2-20*y,0,1,1,10,10)
        end
    end
    for i=1,preview do
        local nextp=blocks[next[i]]
        for J=1,#nextp do
            local x=#field[1]/2+2+noffset[next[i]][1]+nextp[J][1]
            local y=8+noffset[next[i]][2]+nextp[J][2]-2.5*(i-1)
            gc.draw(texture[next[i]],width/2+20*x,height/2-20*y,0,1,1,10,10)
        end
    end
    gc.setColor(1,1,1)
    gc.rectangle("line",width/2-100,height/2-200,200,400)
    gc.rectangle("fill",width/2-100,height/2+210,175*(1-landtime/lockdelay),10)
    gc.print(""..re_chance,Exo_2,width/2+80,height/2+200,0,0.15625,0.15625)
    for i=1,#bag do
        gc.print(bag[i],Exo_2,40+16*i,40,0,0.2,0.2)
    end 
    for J=1,#next do
        gc.print(""..next[J],Exo_2,40+16*J,64,0,0.2,0.2)
    end
    gc.print(""..love.timer.getFPS(),Exo_2,2,height-18,0,1/8,1/8)
    gc.print(lastkey,Exo_2,2,height/2,0,.25,.25)
end