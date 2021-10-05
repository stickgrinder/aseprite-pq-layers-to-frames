-- Ensure we can use UI stuff
if not app.isUIAvailable then
    return
end

-- Ensure a sprite is loaded
if app.activeSprite == nil then
    app.alert("You must open a sprite first to use this script!")
    return
end

-- Get sprite data
local sprite = app.activeSprite
local tagsTable = {}
local tagsLayerIndex = 0    -- not nice to use this var, but indexes in layers
                            -- stack are messed around when there are groups

-- Distribute layers to frame
local function layersToFrames(layers)
    for i,layer in ipairs(layers) do
        -- descend into groups
        if layer.isGroup then
            layersToFrames(layer.layers)
            goto continue -- This early exit workaround sucks, sorry mom
        end

        --print (tagsLayerIndex)
        -- for actual layers, add a new frame and cell
        local newFrame = sprite:newEmptyFrame()
        local newCel   = sprite:newCel(layer, newFrame)
        
        -- copy the first cel of this layer
        -- to the cell of the new frame in the same layer
        newCel.image = layer:cel(1).image
        newCel.position = layer:cel(1).position

        -- take note of the tag position and name
        -- incement before use, since the first frame
        -- is always to skip (tagging starts from 2)
        tagsLayerIndex = tagsLayerIndex + 1
        tagsTable[tagsLayerIndex] = layer.name

        ::continue:: -- I hate Lua and myself
    end
end

local function reset()
    -- delete all frames but the first one
    while #sprite.frames > 1 do
        sprite:deleteFrame(sprite.frames[2])
    end
    for i,tag in ipairs(sprite.tags) do
        sprite:deleteTag(tag)
    end
end

local function addTags()
    for tagFrameNumber, tagName in ipairs(tagsTable) do
        local newTag = sprite:newTag(tagFrameNumber+1, tagFrameNumber+1)
        newTag.name = tagName
    end
end

-- Make sure the user knows what she's doing
local dlg = Dialog()

-- Buttons
dlg:label{ text="This will erase all frames after the first one and re-create them from first frame of each layer. Do you want to continue?" }
dlg:button{ id="go", text="Yes, go" }
dlg:button{ id="cancel", text="Nooo!" }

-- Show the dialog
dlg:show()

-- Get dialog data
local data = dlg.data

-- Stop on cancel
if data.cancel then
    return
end

-- Stop on X
if not data.go then
    return
end

app.transaction(
    function()
        reset()
        layersToFrames(sprite.layers)
        addTags()
    end
)

