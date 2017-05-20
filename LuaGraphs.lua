--Graph implementation in Lua for GraphGPS
--Made by Mario Bizcocho González for Discrete Mathematics

--[[This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
	To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.]]--


--[[
Bibliography:
· http://nova-fusion.com/2011/06/30/lua-metatables-tutorial/
· http://lua-users.org/wiki/MetatableEvents
· http://lua-users.org/wiki/ObjectOrientationTutorial
· http://www.redblobgames.com/pathfinding/a-star/introduction.html
· https://www.lua.org/pil/contents.html
· https://www.youtube.com/watch?v=ySN5Wnu88nE
· http://web.mit.edu/eranki/www/tutorials/search/
]]--

-- AUXILIARY FUNCTIONS

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function getPartialByVertex(vertex,h1,h2)
	a1=h1:getByVertex(vertex)
	a2=h2:getByVertex(vertex)
	wf(tostring(a1))
	wf(tostring(a2))
	if a1~=nil then return a1 end
	if a2~=nil then return a2 end
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

function HeuristicQueue.__tostring(self)
	ans="{\n"
	for _,v in ipairs(self) do
		ans=ans.."[ "..v[1].VertexNow.vertexKey..", "..v[1].costSoFar..", "..v[2].." ]\n"
	end
	return ans.." }"
end
function HeuristicQueue.store(self,elem,heuristic)
	table.insert(self,{elem,heuristic})
end
function HeuristicQueue.pop(self,elem)
	for i,v in ipairs(self) do
		if v[1]==elem then
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
			return v[1]
		end
	end
	return nil
end
function HeuristicQueue.new()
	return setmetatable({},HeuristicQueue)
end

-- ASTARPARTIAL FUNCTIONS

function AStarPartial.combHeuristic(self)
	return self.combinatoryHeuristic
end
function AStarPartial.__eq(p1,p2)
	return p1.VertexNow==p2.VertexNow
end
function AStarPartial.dist(self)
	return distance(self.VertexNow.vertexCoords[1],self.VertexNow.vertexCoords[2],self.VertexPrevious.vertexCoords[1],self.VertexPrevious.vertexCoords[2])
end
function AStarPartial.new(v1,v2,csf,combH)
	t={}
	t=setmetatable(t,AStarPartial)
	t.VertexNow=v1
	t.VertexPrevious=v2
	t.costSoFar=csf
	t.combinatoryHeuristic=combH
	return t
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
function Graph.getEdgeConnecting(self,v1,v2)
	local i = self:findVertex(v1)
	for _,edge in ipairs(self[i]) do
		if edge.Vertex1==v2 or edge.Vertex2==v2 then
			return edge
		end
	end
end
function Graph.getDistanceToVertex(self,origin,v)
	if (type(v)=="table" and getmetatable(v)==Vertex and type(origin)=="table" and getmetatable(origin)==Vertex) then
		pos1=origin.vertexCoords
		pos2=v.vertexCoords
		return distance(pos1[1],pos1[2],pos2[1],pos2[2])
	end
end
function wf(d)
	if isDebug then
		f=fs.open("log.log", "a")
		f.write(d.."\n")
		f.close()
	end
end
function Graph.getPathAStar(self,origin,v)																									-- A* ALGORITHM IS HERE
	wf("Empezamos nuevamente")
	if type(origin)=="number" then
		origin=self:findVertexId(origin)
	end
	if type(v)=="number" then
		v=self:findVertexId(v)
	end
	current=origin
	currPartial=AStarPartial.new(origin,origin,0,self:getDistanceToVertex(origin,v))
	hq=HeuristicQueue.new()
	FinishedElements=HeuristicQueue.new()
	hq:store(currPartial,currPartial:combHeuristic())
	while current~=v do
		for i,elem in ipairs(self:getAdjacentVertices(current)) do
			edge=self:getEdgeConnecting(current,elem)
			wf("Expandiendo vertice: "..current.vertexKey..", vertice actual: "..elem.vertexKey)
			wf("Contenido de hq: "..tostring(hq))
			elemPartial=AStarPartial.new(elem,current,currPartial.costSoFar+edge.weight,self:getDistanceToVertex(elem,v)+edge.weight)
			if hq:contains(elem) then
				thisPartial=hq:getByVertex(elem)
				wf(tostring(thisPartial.costSoFar))
				wf(tostring(elemPartial.costSoFar))
				if thisPartial.costSoFar>elemPartial.costSoFar then
					thisPartial=elemPartial
				end
			elseif FinishedElements:contains(elem) then
				thisPartial=FinishedElements:getByVertex(elem)
				if thisPartial.costSoFar>elemPartial.costSoFar then
					thisPartial=elemPartial
				end
			else
				hq:store(elemPartial,elemPartial:combHeuristic())
			end
		end
		FinishedElements:store(currPartial,currPartial:combHeuristic())
		hq:pop(currPartial)
		currPartial=hq:elemLeastHeuristic()
		current=currPartial.VertexNow
		wf("Ahora el vertice es: "..current.vertexKey)
		wf("Contenido de hq: "..tostring(hq))
	end
	wf("Terminada primera fase; recopilando vertices")
	ans={current}
	while current~=origin do
		wf("Vertice actual: "..current.vertexKey)
		currPartial=getPartialByVertex(currPartial.VertexPrevious,hq,FinishedElements)
		current=currPartial.VertexNow
		table.insert(ans,1,current)
	end
	wf("Vertice actual: "..current.vertexKey)
	wf("Algoritmo terminado con exito")
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

function DirEdge.__tostring(self)
	return self.Vertex1.vertexKey.." - "..self.Vertex2.vertexKey.." (".. self.weight ..")"
end
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