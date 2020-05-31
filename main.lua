PLUGIN = nil

function Initialize(Plugin)
	Plugin:SetName("ChunkStatistics")
	Plugin:SetVersion(2)

	-- Hooks

	PLUGIN = Plugin -- NOTE: only needed if you want OnDisable() to use GetName() or something like that

	-- Command Bindings
	cPluginManager.BindCommand("/statistics", "derpyplugin.statistics", countChunks, " ~ Statistics chunk");

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end

function countChunks(Split, Player) 
  LOG(PLUGIN:GetName() .. " is making statistics of blocks...")
  
  local countArray = {}
  for i=0, 1000 do
    countArray[i] = 0
  end
  
  local chunkCount = 0
  local radius = 10
  for i=-radius, radius do
    for j=-radius, radius do
      if i*i + j*j<= radius*radius then
        local X = (Player:GetChunkX() + i)
        local Z = (Player:GetChunkZ() + j)
        LOG(PLUGIN:GetName() .. " is counting blocks in chunk: (" .. X .. ", " .. Z .. ")")
        
        local result = countBlocksInChunk(Player:GetWorld(), X, Z)
        if (result[0] ~= 65536) then
          chunkCount = chunkCount +1
          for i=0, 1000 do
            countArray[i] = countArray[i] + result[i]
          end
        end
      end
    end
  end
  
  LOG(PLUGIN:GetName() .. "is saving statistics of blocks...)")
  saveStatistics(countArray , chunkCount)
  return true
end

function saveStatistics(blockCountArray, chunkCount)
	local SettingsIni = cIniFile();
  local fileName = "Plugins/ChunkStatistics/" .. os.date("%X") .. ".ini"
	SettingsIni:ReadFile(fileName);  -- ignore any read errors
  SettingsIni:GetValueSetI("[Statistics]",   "chunk-count",  chunkCount)
  
  local total = 0
  for i=0, 1000 do
    SettingsIni:GetValueSetI("[Statistics]",   "id" .. i,  blockCountArray[i])
  end
	SettingsIni:WriteFile(fileName);
end


-- world: object of world
-- positionX: chunk's position x
-- positionZ: chunk's position Z
-- @return: array of block statistics
function countBlocksInChunk(world, positionX, positionZ)
  local countArray = {}
  for i=0, 1000 do
    countArray[i] = 0
  end

  local originX = positionX*16
  local originZ = positionZ*16

  for i = 0,15,1
  do 
    for j = 0,255,1
    do 
      for k = 0,15,1
      do 
        local x = originX + i
        local y = j
        local z = originZ +k
        local blockType = world:GetBlock(x,y,z)
        if blockType ~= 1 then
            --LOG(PLUGIN:GetName() .. ": debug")
        end
        countArray[blockType] = countArray[blockType] + 1
      end
    end
  end
  return countArray
end

function StatisticsOneChunk(Split, Player)
  local originX = Player:GetChunkX()*16
  local originZ = Player:GetChunkZ()*16
  local count = {}
  for i=0, 1000 do
    count[i] = 0
  end

  for i = 0,15,1
  do 
    for j = 0,255,1
    do 
      for k = 0,15,1
      do 
        local x = originX + i
        local y = j
        local z = originZ +k
        local blockType = Player:GetWorld():GetBlock(x,y,z)
        if(blockType==21) then
          Player:GetWorld():DigBlock(x,y,z)
        end
        count[blockType] = count[blockType] + 1
      end
    end
  end

  -- record statistics
  LOG(PLUGIN:GetName() .. ": calculating amount of blocks...")
	local SettingsIni = cIniFile();
	SettingsIni:ReadFile("ChunkStatistics.ini");  -- ignore any read errors

  for i=0, 1000 do
    SettingsIni:GetValueSetI("[Statistics]",   "id" .. i,  count[i])
  end
	SettingsIni:WriteFile("ChunkStatistics.ini");
  return true
end
