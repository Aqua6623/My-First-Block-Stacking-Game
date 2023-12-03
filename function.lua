--实用
function isEqual(a,b)--检测两列表是否相同
    for i=1,#a do
        if type(a)~=type(b) then return false end
        local c,d=a[i],b[i]
        if type(c)=='table' or type(d)=='table' then
            if not isEqual(c,d) then return false end
        elseif c~=d then return false end
    end
    return true
end
function include(a,b)--检测b中有无a元素
    for i=1,#b do
        if type(a)==type(b[i]) then
            if type(a)=='table' then
            if isEqual(a,b[i]) then return true,i end
            elseif a==b[i] then return true,i end
        end
    end
    return false,0
end
function copy(list)--复制列表(必须是从1开始的连续数字索引)
    local clone={}
    for i=1,#list do 
        if type(list[i])=="table" then clone[i]=copy(list[i])
        else clone[i]=list[i] end
    end
    return clone
end
function shuffle(list)--洗牌
    local mess=copy(list)
    for i=#mess,1,-1 do
        table.insert(mess,table.remove(mess,math.random(i)))
    end
    return mess
end
function vecplus(a,b)--矢量叠加
    local l=math.min(#a,#b) local c={}
    for i=1,l do c[i]=a[i]+b[i] end
    if #a>#b then for i=l+1,#a do c[i]=a[i] end
    elseif #b>#a then for i=l+1,#a do c[i]=a[i] end
    end  return c
end
function vecmult(v,k)--矢量放缩
    local m={}
    for i=1,#v do m[i]=v[i]*k end
    return m
end
function compmult(a,b)--复数相乘
    local m={}
    m[1]=a[1]*b[1]-a[2]*b[2]
    m[2]=a[2]*b[1]+a[1]*b[2]
    return m
end

--绘图用
function picO(texture)
    return texture:getPixelWidth()/2,texture:getPixelHeight()/2
end
--方块相关
function summonfield(line,height)
    local fld={}
    for j=1,height do fld[j]=copy(line) end  return fld
end
function summonline(element,length)
    local line={}
    for i=1,length do line[i]=element end  return line
end
function addline(field)
    local l={}
    for i=1,#field[1] do l[i]=' ' end
    table.insert(field,copy(l))
end
function rotate(b,o,mode)--mode='R'是顺时针 'L'是逆时针 'F'是180
    local spin={R=1,L=-1,F=2} local newb=copy(b)
    for i=1,#newb do
        if mode=='F' then newb[i][2]=newb[i][2]*(-1) newb[i][1]=newb[i][1]*(-1) else
        newb[i][1],newb[i][2]=newb[i][2],newb[i][1]
        if mode=='R' then newb[i][2]=newb[i][2]*(-1)
        else newb[i][1]=newb[i][1]*(-1) end end
    end
    o=(o+spin[mode])%4 return newb,o
end
--Z 酱 锐 评：压得过于离谱，你一个月不看都不敢动的那种
function kick(b,o,mode,name,px,py,field,loosen,RS)
    local newb,newo=rotate(b,o,mode) local spin={R=1,L=5,F=9}
    local ukick=RS[name][o+spin[mode]]
    for i=1,#ukick do
        local x,y=px+ukick[i][1],py+ukick[i][2]
        if not coincide(field,loosen,x,y,newb) then return newb,newo,x,y, true,i end
    end
    return b,o,px,py, false,0
end

function coincide(field,loosen,px,py,piece)--是否重叠
    for i=1,#piece do
        local x=piece[i][1]+px
        local y=piece[i][2]+py
        if y<1 or x<1 or x>#field[1] then return true end
        if field[y][x]~=' ' then return true end
    end

    for i=1,#piece do 
        local realpiece=vecplus(piece[i],{px,py})
        if include(realpiece,loosen) then return true end
    end
    return false
end
function getghostpos(field,loosen,px,py,piece)
    if #piece==0 then return px,py end
    local gpy=py
    while not coincide(field,loosen,px,gpy-1,piece) do gpy=gpy-1 end
    return px,gpy
end
function lock(piece,name,px,py,field)
    for i=1,#piece do
        local x=px+piece[i][1]
        local y=py+piece[i][2]
        field[y][x]=name
    end
end
function line_clear(field)
    local cunt=0--粗 鄙 之 语
    for y=#field,1,-1 do--正序遍历会出问题
        local pass=true
        for x=1,#field[1] do
            if field[y][x]==' ' then pass=false break end
        end
        if pass then table.remove(field,y)
        addline(field) cunt=cunt+1 end
    end
    return cunt--消了几行
end
function freefall(piece,name,px,py,field)
    for i=1,#field do  for j=#piece,1,-1 do
        if piece[j][2]+py==i then
            local x,y=px+piece[j][1],py+piece[j][2]
            if y==1 or field[y-1][x]~=' ' then
                field[y][x]=name table.remove(piece,j)
            end
        end
    end end
    return px,py-1
end
--为O-spin所做的准备
function loosen_fall(loosen,field,name)
    for y=1,#field do  for i=#loosen,1,-1 do
        if loosen[i][2]==y then
            if y==1 or field[loosen[i][2]-1][loosen[i][1]]~=' ' then
            field[loosen[i][2]][loosen[i][1]]=name
            table.remove(loosen,i)
            end
        end
    end  end
    for i=1,#loosen do loosen[i][2]=loosen[i][2]-1 end
end
function check_loose_move(piece,px,py,mode,field,loosen,spincount)
    local dir={L={-1,0},R={1,0},D={0,-1}}
    local testpnt,blocktomove={},{} local canmove,moretest=true,true
    for i=1,#piece do testpnt[i]=vecplus(piece[i],vecplus(dir[mode],{px,py})) end
    --[[第一次检测，若检测到固定块则开启旋转计数且松动块不可移动，且不启动之后的检测
    若旋转计数>=3，将对应固定块转化为松动块
    若检测到松动块则将其移出loosen列表，加入blocktomove列表，检查点向指定方向移一格
    若检查点上啥都没有，销毁该检查点]]
    for i=#testpnt,1,-1 do
        local loosedetect,seqnum=include(testpnt[i],loosen)
        if testpnt[i][1]>#field[1] or testpnt[i][1]<1 or testpnt[i][2]<1 then canmove=false moretest=false
            table.remove(testpnt,i)
        elseif field[testpnt[i][2]][testpnt[i][1]]~=' ' then
            canmove=false moretest=false
            if spincount>=3 then
                field[testpnt[i][2]][testpnt[i][1]]=' '
                table.insert(loosen,testpnt[i])
            end
            table.remove(testpnt,i)
        elseif loosedetect then
            table.insert(blocktomove,table.remove(loosen,seqnum))
            testpnt[i]=vecplus(testpnt[i],dir[mode])
        else table.remove(testpnt,i) end
    end
    --[[第二次检测，若检测到固定块则将其转化为松动块，松动块不可移动
    若检测到松动块，同上，但是循环
    其它同上]]
    if moretest then  for i=#testpnt,1,-1 do
        local loosedetect,seqnum=include(testpnt[i],loosen)
        if testpnt[i][1]>#field[1] or testpnt[i][1]<1 then canmove=false
        elseif field[testpnt[i][2]][testpnt[i][1]]~=' ' then
            canmove=false field[testpnt[i][2]][testpnt[i][1]]=' '
            table.insert(loosen,copy(testpnt[i]))
        elseif loosedetect then 
            while loosedetect do
                table.insert(blocktomove,table.remove(loosen,seqnum))
                testpnt[i]=vecplus(testpnt[i],dir[mode])
                loosedetect,seqnum=include(testpnt[i],loosen)
            end
            if testpnt[i][1]>#field[1] or testpnt[i][1]<1 or testpnt[i][2]<1 then canmove=false
            elseif field[testpnt[i][2]][testpnt[i][1]]~=' ' then
                canmove=false field[testpnt[i][2]][testpnt[i][1]]=' '
                table.insert(loosen,testpnt[i])
            end
        end
        table.remove(testpnt,i)
    end  end
    --[[最后，若可以移动，处于blocktomove的块全部向指定方向移一格
    然后把blocktomove里的东西重新放回loosen]]
    if canmove then
        for i=1,#blocktomove do blocktomove[i]=vecplus(blocktomove[i],dir[mode]) end
    end
    for i=#blocktomove,1,-1 do table.insert(loosen,copy(blocktomove[i])) end
end