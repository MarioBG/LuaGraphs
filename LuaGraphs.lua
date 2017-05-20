--Graph implementation in Lua for GraphGPS
--Made by Mario Bizcocho González for Discrete Mathematics
--(C) Mar&Mar Hisperia 2017. All rights reserved.

--[[
Bibliography:
· http://nova-fusion.com/2011/06/30/lua-metatables-tutorial/
· http://lua-users.org/wiki/MetatableEvents
· http://lua-users.org/wiki/ObjectOrientationTutorial
· http://www.redblobgames.com/pathfinding/a-star/introduction.html
· https://www.lua.org/pil/contents.html
· https://www.youtube.com/watch?v=ySN5Wnu88nE
]]--

-- AUXILIARY TABLE FUNCTION

function print_r ( t )  
	ans=""
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            ans=ans..(indent.."*"..tostring(t).."\n")
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        ans=ans..(indent.."["..pos.."] => "..tostring(t).." {\n")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        ans=ans..(indent..string.rep(" ",string.len(pos)+6).."}\n")
                    elseif (type(val)=="string") then
                        ans=ans..(indent.."["..pos..'] => "'..val..'"'.."\n")
                    else
                        ans=ans..(indent.."["..pos.."] => "..tostring(val).."\n")
                    end
                end
            else
                ans=ans..(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        ans=ans..(tostring(t).." {\n")
        sub_print_r(t,"  ")
        ans=ans..("}\n")
    else
        sub_print_r(t,"  ")
    end
    ans=ans.."\n"
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function table.find(table, element)
  for key, value in pairs(table) do
    if value == element then
      return key
    end
  end
  return nil
end

-- A* AUXILIARY FUNCTIONS

local INF=1/0

local function distance(a1,a2,b1,b2)
	return math.sqrt(math.pow(a1-b1,2)+math.pow(a2-b2,2))
end

-- DECLARATION OF ALL TABLES AND __index SETTING

isDebug = true

luaGraphVersion = "0.1"
local vertexKeyIndexTable={}

FinishedElements={}
Graph={}
Graph.__index = Graph
Digraph={}
Digraph.__index = Digraph
Vertex={}
Vertex.__index = Vertex
UEdge={}
UEdge.__index = UEdge
DirEdge={}
DirEdge.__index = DirEdge
HeuristicQueue={}
HeuristicQueue.__index = HeuristicQueue
AStarPartial={}
AStarPartial.__index = AStarPartial

-- PRIORITYQUEUE FUNCTIONS

function HeuristicQueue.new()
	return setmetatable({},HeuristicQueue)
end
function HeuristicQueue.__tostring(self)
	print_r(self)
end
function HeuristicQueue.store(self,elem,heuristic)
	table.insert(self,{elem,heuristic})
end
function HeuristicQueue.pop(self,elem)
	for i,v in ipairs(self) do
		if v==elem then
			table.remove(self,i)
			return true
		end
	end
	return false
end
function HeuristicQueue.elemLeastHeuristic(self)
	local lowestH, bestV = INF, nil
	for _,v in ipairs(self) do
		if v[2]<lowestH then
			ans=v[1]
			lowestH=v[2]
		end
	end
	return ans
end
function HeuristicQueue.setPriority(self,elem,heuristic)
	for _,v in ipairs(self) do
		if v[1]==elem then
			v[2]=heuristic
			ans=v
		end
	end
end
function HeuristicQueue.contains(self,elem)
	for _,v in ipairs(self) do
		if v[1].VertexNow==elem then
			return true
		end
	end
	return false
end
function HeuristicQueue.getByVertex(self,elem)
	for _,v in ipairs(self) do
		if v[1].VertexNow==elem then
			return v
		end
	end
	return nil
end

-- ASTARPARTIAL FUNCTIONS

function AStarPartial.new(v1,v2,csf)
	t={}
	setmetatable(t,AStarPartial)
	t.VertexNow=v1
	t.VertexPrevious=v2
	t.costSoFar=csf
	return t
end
function AStarPartial.combHeuristic(self)
	return self:dist()+self.costSoFar
end
function AStarPartial.dist(self)
	return distance(self.VertexNow.vertexCoords[1],self.VertexNow.vertexCoords[2],self.VertexPrevious.vertexCoords[1],self.VertexPrevious.vertexCoords[2])
end

-- GRAPH FUNCTIONS

function Graph.new(name, isDirected)
  t={}
  t=setmetatable(t,Graph)
  t:setName(name)
  t.graphVersion = luaGraphVersion
  t.isDirected = isDirected
  return t
end
function Graph.addVertex(self,v)
	if getmetatable(v)==Vertex and not table.contains(self, v) then
		table.insert(self,{v})
	end
end
function Graph.findVertex(self,v)
	for i=1,table.getn(self) do
		if (self[i][1]==v or self[i][1].vertexKey==v) then
			return i
		end
	end
	return nil
end
function Graph.setName(self,name)
  self.graphName=name
end
function Graph.getName(self)
  return self.graphName
end
function Graph.findVertexId(self,id)
	if (type(id)=="table" and getmetatable(id)==Vertex) then
		for i,v in ipairs(self) do
			if (v[1]==id) then return v[1] end
		end
	elseif (type(id)=="number") then
		for i,v in ipairs(self) do
			if (v[1].vertexKey==id) then return v[1] end
		end
	end
	return nil
end
function Graph.joinVertices(self,v1,v2,weight)
	if type(v1)=="table" and type(v2)=="table" and getmetatable(v1)==Vertex and getmetatable(v2)==Vertex then
		if self.isDirected then
			edge=DirEdge.joinVertices(v1,v2,weight)
		else
			edge=UEdge.joinVertices(v1,v2,weight)
			edge2=UEdge.joinVertices(v2,v1,weight)
			local i=self:findVertex(v2)
			if i~=nil then
				table.insert(self[i],edge2)
			else return false end
		end
		local i=self:findVertex(v2)
		if i~=nil then
			table.insert(self[i],edge)
		else return false end
	else return false end
	return true
end
function Graph.joinVertsDistAndMult(self,v1,v2,mult)
	if type(v1)=="table" and type(v2)=="table" and getmetatable(v1)==Vertex and getmetatable(v2)==Vertex then
		dist=distance(v1.vertexCoords[1],v1.vertexCoords[2],v2.vertexCoords[1],v2.vertexCoords[2])*mult
		return self:joinVertices(v1,v2,dist)
	elseif type(v1)=="number" and type(v2)=="number" then
		v1=self:findVertexId(v1)
		v2=self:findVertexId(v2)
		dist=self:getDistanceToVertex(v1,v2)
		return self:joinVertices(v1,v2,dist)
	end
end
function Graph.joinVDMBothDirs(self,v1,v2,mult)
	self:joinVertsDistAndMult(v1,v2,mult)
	self:joinVertsDistAndMult(v2,v1,mult)
end
function Graph.getAdjacentVertices(self,v)
	ans={}
	if (type(v)=="table" and getmetatable(v)==Vertex) then
		for i,a in ipairs(self[self:findVertex(v)]) do
			if i>1 then
				table.insert(ans,a.Vertex1)
			end
		end
	end
	return ans
end
function Graph.getDistanceToVertex(self,origin,v)
	if (type(v)=="table" and getmetatable(v)==Vertex and type(origin)=="table" and getmetatable(origin)==Vertex) then
		pos1=origin.vertexCoords
		pos2=v.vertexCoords
		return distance(pos1[1],pos1[2],pos2[1],pos2[2])
	end
end
function wf(d)
	f=fs.open("log.log", "a")
	f.write(d)
	f.close()
end
function Graph.getPathAStar(self,origin,v)																									-- A* ALGORITHM IS HERE
	if type(origin)=="number" then
		origin=self:findVertexId(origin)
	end
	if type(v)=="number" then
		v=self:findVertexId(v)
	end
	current=origin
	currPartial=AStarPartial.new(origin,origin,0)
	hq=HeuristicQueue.new()
	while current~=v do
		for _,elem in ipairs(self:getAdjacentVertices(current)) do
			wf("Ciclo A: "..elem.vertexKey)
		end
		for _,elem in ipairs(self:getAdjacentVertices(current)) do
			if hq:contains(elem) then
				elemPartial=AStarPartial.new(elem,current,currPartial.costSoFar+self:getDistanceToVertex(current,origin))
				thisPartial=hq:getByVertex(elem)
				if thisPartial.costSoFar>elemPartial.costSoFar then
					thisPartial=elemPartial
				end
			else
				elemPartial=AStarPartial.new(elem,current,currPartial.costSoFar+self:getDistanceToVertex(current,origin))
				hq:store(elemPartial,elemPartial:combHeuristic())
			end
		end
		table.insert(FinishedElements, currPartial)
		hq:pop(currPartial)
		currPartial=hq:elemLeastHeuristic()
		if currPartial==nil or getmetatable(currPartial)~=AStarPartial then error("Sa chingao acho") end
		--print(currPartial.VertexNow.vertexKey)
		current=currPartial.VertexNow
		wf("Ciclo B: "..current.vertexKey)
	end
end

--VERTEX FUNCTIONS

function Vertex.new(name, coords, vKey)
	t={}
	t=setmetatable(t,Vertex)
	t.vertexName = name
	if vKey==nil then
		local vKey=math.random(0,100000000)
		while (table.contains(vertexKeyIndexTable, vKey)) do
			local vKey=math.random(0,100000000)
		end
	end
	t.vertexKey = (vKey)
	t.vertexCoords = coords
	return t
end
function Vertex.__eq(v1,v2)
	return v1.vertexKey==v2.vertexKey
end

--UEDGE FUNCTIONS

function UEdge.joinVertices(v1,v2,weight)
	if getmetatable(v1)==Vertex and getmetatable(v2)==Vertex then
		t={}
		t=setmetatable(t,UEdge)
		t.Vertex1=v1
		t.Vertex2=v2
		if weight~=nil and type(weight)=="number" then
			t.weight=weight
		else
			t.weight=1
		end
		return t
	end
end

--DIREDGE FUNCTIONS

function DirEdge.joinVertices(v1,v2,weight)
	if getmetatable(v1)==Vertex and getmetatable(v2)==Vertex then
		t={}
		t=setmetatable(t,DirEdge)
		t.Vertex1=v1
		t.Vertex2=v2
		if weight~=nil and type(weight)=="number" then
			t.weight=weight
		else
			t.weight=1
		end
		return t
	end
end