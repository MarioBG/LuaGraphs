--GraphGPS, geolocation and pathfinding program for Minecraftian topography
--Made by Mario Bizcocho González for Discrete Mathematics

--[[This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
	To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.]]--

tx,ty=term.getSize()
modem=peripheral.wrap("back")

function math.round(n)
	if n-math.floor(n)>=0.5 then
		return math.ceil(n)
	else
		return math.floor(n)
	end
end
local function split(str, max_line_length)
   local lineas = {}
   local line
   str:gsub('(%s*)(%S+)', 
      function(spc, word) 
         if not line or #line + #spc + #word > max_line_length then
            table.insert(lineas, line)
            line = word
         else
            line = line..spc..word
         end
      end
   )
   table.insert(lineas, line)
   return lineas
end
function writeCenter(txt,line)
	local tx,ty=term.getSize()
	term.setCursorPos(1+tx/2-#txt/2,line)
	write(txt)
end


-- DECLARE MINEVILLE CITY GRAPH VERTEX

mineville=Graph.new("Mineville", true)
mineville:addVertex(Vertex.new("Calle Aura Garrido (Puente)", {-333,237},1))
mineville:addVertex(Vertex.new("Calle Aura Garrido-pasadizo", {-393, 237},2))
mineville:addVertex(Vertex.new("Calle Aura Garrido-Calle Reina Mercedes", {-402, 237},3))
mineville:addVertex(Vertex.new("Calle Aura Garrido", {-421, 237},4))
mineville:addVertex(Vertex.new("Avda. Dr. Rodolfo Sancho", {-437, 234},5))
mineville:addVertex(Vertex.new("Avda. Dr. Rodolfo Sancho-MdT", {-437, 219},6))
mineville:addVertex(Vertex.new("Avda. Dr. Rodolfo Sancho-Calle Suarez", {-437, 170},7))
mineville:addVertex(Vertex.new("Plaza Piccadilly", {-416, 169},8))
mineville:addVertex(Vertex.new("Plaza Piccadilly", {-392, 169},9))
mineville:addVertex(Vertex.new("Plaza Piccadilly", {-402, 190},10))
mineville:addVertex(Vertex.new("Plaza Piccadilly", {-402, 132},11))
mineville:addVertex(Vertex.new("Bosque", {-452, 157},12))
mineville:addVertex(Vertex.new("Taiga", {-450, 122},13))
mineville:addVertex(Vertex.new("Taiga", {-403, 123},14))
mineville:addVertex(Vertex.new("Taiga", {-402, 82},15))
mineville:addVertex(Vertex.new("Taiga", {-402, 93},16))
mineville:addVertex(Vertex.new("Peninsula del Pantano", {-478, 69},17))
mineville:addVertex(Vertex.new("Taiga", {-460, 125},18))
mineville:addVertex(Vertex.new("Calle Suarez", {-464, 170},19))
mineville:addVertex(Vertex.new("Calle Suarez-Nacional III", {-464, 211},20))
mineville:addVertex(Vertex.new("Nacional III-Fabrica Mar&Mar", {-508, 211},21))
mineville:addVertex(Vertex.new("Fabrica Mar&Mar", {-506, 237},22))
mineville:addVertex(Vertex.new("Calle Suarez-Calle Pacino", {-465, 219},23))
mineville:addVertex(Vertex.new("Calle Suarez-Calle Innovacion", {-465, 264},24))
mineville:addVertex(Vertex.new("Plaza de la Revolucion", {-434, 266},25))
mineville:addVertex(Vertex.new("Plaza de la Revolucion-Calle Aura Garrido", {-421, 266},26))
mineville:addVertex(Vertex.new("Calle Innovacion-pasadizo", {-393, 265},27))
mineville:addVertex(Vertex.new("Calle Innovacion-mirador", {-372, 265},28))
mineville:addVertex(Vertex.new("Calle Innovacion-Calle Motus", {-372, 271},29))
mineville:addVertex(Vertex.new("Calle Roble (granja)", {-357, 168},32))
mineville:addVertex(Vertex.new("Calle Roble-Calle Atocha-Calle Twitter", {-339, 172},31))
mineville:addVertex(Vertex.new("Calle Motus-Calle Twitter", {-333, 271},33))
mineville:addVertex(Vertex.new("Avda. Dr. Rodolfo Sancho-Calle Ascension", {-436, 311},34))
mineville:addVertex(Vertex.new("Calle Suarez-Calle Ascension", {-464, 311},35))
mineville:addVertex(Vertex.new("Hanging Tree Sq-Calle Castilla", {-483, 358},36))
mineville:addVertex(Vertex.new("Hanging Tree Sq-Calle Suarez-Calle Fraternidad", {-464, 358},37))
mineville:addVertex(Vertex.new("Avda. de la Democracia-Calle Fraternidad", {-436, 359},38))
mineville:addVertex(Vertex.new("Calle Innovacion-Calle Sevilla", {-372, 346},39))
mineville:addVertex(Vertex.new("Calle Innovacion-Calle Fraternidad", {-372, 359},40))
mineville:addVertex(Vertex.new("Avda. del Ciudadano-Torre Mar&Mar", {-368, 397},41))
mineville:addVertex(Vertex.new("Avda. de la Democracia-TGPF", {-432, 434},42))
mineville:addVertex(Vertex.new("Calle Castilla", {-483, 440},43))
mineville:addVertex(Vertex.new("Avda. Constitucion-Avda. del Ciudadano", {-372, 374},44))
mineville:addVertex(Vertex.new("Avda. del Ciudadano-CC. David Tennant", {-368, 434},45))
mineville:addVertex(Vertex.new("Avda. del Ciudadano-Calle del Eliseo", {-368, 447},46))
mineville:addVertex(Vertex.new("Calle del Eliseo-Calle Valladolid", {-322, 447},47))
mineville:addVertex(Vertex.new("Avda. de la Constitucion (reloj Mar&Mar)", {-331, 372},48))
mineville:addVertex(Vertex.new("Avda. de la Constitucion (Naciones Unidas)", {-299, 372},49))
mineville:addVertex(Vertex.new("Plaza del Triunfo", {-303, 448},50))
mineville:addVertex(Vertex.new("Plaza del Triunfo-Monzuela", {-274, 448},51))
mineville:addVertex(Vertex.new("Avda. de la Constitucion-Calle Fontenla", {-244, 373},52))
mineville:addVertex(Vertex.new("Calle Fontenla (Domicilio Presidencial, TVH)", {-245, 344},53))
mineville:joinVertsDistAndMult(1,2,1)
mineville:joinVertsDistAndMult(2,1,1)
mineville:joinVertsDistAndMult(2,3,1)
mineville:joinVertsDistAndMult(3,2,1)
mineville:joinVertsDistAndMult(4,3,1)
mineville:joinVertsDistAndMult(3,4,1)
mineville:joinVDMBothDirs(4,26,1)
mineville:joinVertsDistAndMult(3,10,1)
mineville:joinVertsDistAndMult(10,3,1)
mineville:joinVertsDistAndMult(4,5,1.1)
mineville:joinVertsDistAndMult(5,4,1.1)
mineville:joinVDMBothDirs(5,6,0.7)
mineville:joinVDMBothDirs(6,7,0.7)
mineville:joinVDMBothDirs(5,25,0.7)
mineville:joinVDMBothDirs(10,8,0.7)
mineville:joinVDMBothDirs(10,9,0.7)
mineville:joinVDMBothDirs(10,11,0.7)
mineville:joinVDMBothDirs(8,9,0.7)
mineville:joinVDMBothDirs(8,11,0.7)
mineville:joinVDMBothDirs(9,11,0.7)
mineville:joinVDMBothDirs(11,13,1.5)
mineville:joinVDMBothDirs(13,12,2)
mineville:joinVDMBothDirs(20,12,2)
mineville:joinVDMBothDirs(20,19,1)
mineville:joinVDMBothDirs(19,17,1)
mineville:joinVDMBothDirs(20,23,1)
mineville:joinVDMBothDirs(20,21,0.7)
mineville:joinVDMBothDirs(21,22,1)
mineville:joinVDMBothDirs(23,24,1)
mineville:joinVDMBothDirs(23,6,1)
mineville:joinVDMBothDirs(24,25,1)
mineville:joinVDMBothDirs(25,26,1)
mineville:joinVDMBothDirs(26,27,1)
mineville:joinVDMBothDirs(27,2,1.1)
mineville:joinVDMBothDirs(27,28,1)
mineville:joinVDMBothDirs(28,29,1)
mineville:joinVDMBothDirs(29,33,1)
mineville:joinVDMBothDirs(1,33,1)
mineville:joinVDMBothDirs(31,1,1)
mineville:joinVDMBothDirs(9,31,1)
mineville:joinVDMBothDirs(31,32,1)
mineville:joinVDMBothDirs(13,14,2)
mineville:joinVDMBothDirs(13,15,3)
mineville:joinVDMBothDirs(13,18,2)
mineville:joinVDMBothDirs(18,16,3)
mineville:joinVDMBothDirs(16,15,2)
mineville:joinVDMBothDirs(15,14,2)
mineville:joinVDMBothDirs(16,14,2)
mineville:joinVDMBothDirs(16,17,2)
mineville:joinVDMBothDirs(18,17,2)
mineville:joinVDMBothDirs(7,8,1)
mineville:joinVDMBothDirs(29,39,1)
mineville:joinVDMBothDirs(39,40,1)
mineville:joinVDMBothDirs(25,34,1)
mineville:joinVDMBothDirs(24,35,1)
mineville:joinVDMBothDirs(35,34,1)
mineville:joinVDMBothDirs(35,37,1)
mineville:joinVDMBothDirs(34,38,1)
mineville:joinVDMBothDirs(37,38,1)
mineville:joinVDMBothDirs(36,37,1)
mineville:joinVDMBothDirs(36,43,1)
mineville:joinVDMBothDirs(43,42,1)
mineville:joinVDMBothDirs(38,42,0.7)
mineville:joinVDMBothDirs(42,45,1)
mineville:joinVDMBothDirs(38,40,0.7)
mineville:joinVDMBothDirs(40,44,1)
mineville:joinVDMBothDirs(44,48,0.7)
mineville:joinVDMBothDirs(44,41,0.7)
mineville:joinVDMBothDirs(41,45,0.7)
mineville:joinVDMBothDirs(45,46,0.7)
mineville:joinVDMBothDirs(46,47,0.7)
mineville:joinVDMBothDirs(47,50,0.7)
mineville:joinVDMBothDirs(50,51,0.7)
mineville:joinVDMBothDirs(48,49,0.7)
mineville:joinVDMBothDirs(48,47,1.25)
mineville:joinVDMBothDirs(47,49,1.15)
mineville:joinVDMBothDirs(49,52,0.7)
mineville:joinVDMBothDirs(52,53,1)
mineville:joinVertsDistAndMult(12,19,1.5)
mineville:joinVertsDistAndMult(12,7,2)
mineville:joinVertsDistAndMult(14,11,2)

destinos={
{"Monzuela", 51},
{"Turtle",42},
{"Home",53}
}

currentVertex=nil
hasChanged=false
ruta={}

iDestinoActual=nil

function findNextV(tabla,elem)
	for i=1, #tabla do
		if tabla[i][1]==elem and tabla[i+1]~=nil then
			return tabla[i+1]
		elseif tabla[i][1]==elem then
			return true
		end
	end
end
function findNext(tabla,elem)
	for i=1, #tabla do
		if tabla[i]==elem and tabla[i+1]~=nil then
			return tabla[i+1],i+1
		end
	end
end

-- DRAWING FUNCTIONS
function redrawBackground()
	Olive.setColors(colors.white, colors.white)
	shell.run("clear")
	Olive.square(1,ty,tx,1,colors.black)
	Olive.writeAt(2,ty,"<==")
	Olive.writeAt(tx/2-3,ty,"Inicio")
	Olive.writeAt(tx-4, ty, "===")
	redrawGps()
end

function redrawGps()
	Olive.square(1,1,tx,1,colours.grey)
	term.setTextColor(colours.yellow)
	Olive.writeAt(1,1,"X: "..math.round(x)..",Z: "..math.round(z))
end

function chooseDestination()
	redrawBackground()
	Olive.setColors(colors.white,colors.black)
	for i,v in ipairs(destinos) do
		Olive.writeAt(2,3+i*2-1,destinos[i][1])
	end
	if iDestinoActual~=nil then Olive.writeAt(1,3+iDestinoActual*2-1,">") end
	local insLoop=true
	while insLoop do
		e,p1,p2,p3=os.pullEvent()
		if e=="timer" then
			x, _, z = gps.locate(1)
			gpsTemp=os.startTimer(0.5)
			redrawGps()
		elseif e=="mouse_click" then
			if p3~=nil then
				if(p3/2==math.floor(p3/2)) then
					p3=math.floor(p3/2-1)
					if p3>0 and p3<=#destinos then
						Olive.setColors(colors.white,colors.black)
						if iDestinoActual~=nil then Olive.writeAt(1,3+iDestinoActual*2-1," ") end
						iDestinoActual=tonumber(p3)
						if iDestinoActual~=nil then Olive.writeAt(1,3+iDestinoActual*2-1,">") end
						ruta=mineville:getPathAStar(getCurrentVertex(),mineville:findVertexId(destinos[iDestinoActual][2]))
					end
				end
			end
		elseif e=="key" then
			if p1==57 then
				insLoop=false
			end
		end
	end
end

function getCurrentVertex()
	local dist=1/0
	local currentV=nil
	for i=1,#mineville do
		if mineville:getDistanceToVertex(mineville[i][1],Vertex.new("",{x,z}),1337)<dist then
			dist=mineville:getDistanceToVertex(mineville[i][1],Vertex.new("",{x,z}),1337)
			currentV=mineville[i][1]
		end
	end
	if currentVertex~=currentV then hasChanged=true end
	return currentV
end

function drawTexts()
	Olive.square(1,2,tx,ty-2,colors.white)
	Olive.setColors(colors.white,colors.black)
	Olive.writeAt(1,2,"GraphGPS v0.1")
	writeCenter("You\'re currently at:",4)
	nLineas=0
	for i,line in ipairs(split(getCurrentVertex().vertexName,tx)) do
		writeCenter(line, 4+i)
		nLineas=nLineas+1
	end
	if iDestinoActual~=nil then
		writeCenter("Destination:",6+nLineas)
		for i,line in ipairs(split(mineville:findVertexId(destinos[iDestinoActual][2]).vertexName,tx)) do
			nLineas=nLineas+1
			writeCenter(line, 6+nLineas)
		end
		writeCenter("Continue onto:",8+nLineas)
		for i,line in ipairs(split(ruta[2].vertexName,tx)) do
			nLineas=nLineas+1
			writeCenter(line, 8+nLineas)
		end
		writeCenter("(at {"..ruta[2].vertexCoords[1]..", "..ruta[2].vertexCoords[2].."})",9+nLineas)
		
	end
	--print(getCurrentVertex().vertexName)
end

-- PROGRAM START
local bRunning = true
while bRunning do
	x, _, z = gps.locate(1)
	gpsTemp=os.startTimer(0.5)
	redrawBackground(x,z)
	drawTexts()
	local insLoop=true
	while insLoop do
		e,p1,p2,p3=os.pullEvent()
		if e=="timer" then
			x, _, z = gps.locate(1)
			gpsTemp=os.startTimer(0.5)
			redrawGps()
			drawTexts()
			if hasChanged then
				currentVertex=getCurrentVertex()
				if table.contains(ruta,currentVertex) and findNext(ruta,currentVertex)~=nil then
					while(ruta[2]~=findNext(ruta,currentVertex)) do
						table.remove(ruta,1)
					end
					if ruta[2]==nil then iDestinoActual=nil end
				elseif ruta[2]==nil or ruta[1]==nil or not table.contains(ruta,currentVertex) or currentVertex==tabla[1] then
					iDestinoActual=nil
				end
				hasChanged=false
			end
		elseif e=="key" then
			if p1==57 then
				chooseDestination()
				insLoop=false
			end
		end
	end
end







