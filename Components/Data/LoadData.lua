local _, addon = ...

-- Function that dynamically returns a function based on class
-- Example usage: addon:GetTrinketData()(specId)
function addon:GetTrinketData()
    local classId = self.db.char.classId

    -- Construct the method name dynamically
    local methodName = "LoadTrinketsForClass_" .. classId

    -- Return the method if it exists and is a function, otherwise return a dummy function
    if self[methodName] and type(self[methodName]) == "function" then
        return function(specId)
            -- Call the dynamically constructed method with specId
            self[methodName](self, specId)
        end
    else
        return function()
            -- print("Error: Method " .. methodName .. " not found or is not a valid function.")
        end
    end
end

function addon:InitializeDataLoader()
    if self.game ~= "RETAIL" then
        return
    end

    local classId = self.db.char.classId
    local specId = self.db.char.specId

    if not specId then
        -- print("Error: specId is missing.")
        return
    end

    -- Attempt to get trinket data for the given specId
    self:GetTrinketData()(specId)

    -- Unfortunately not all specs have bis data, like healers for example.
    if not self.BisTrinkets then
        -- print("Error: trinket data is not available for specId " .. specId .. ". Attempting fallback...")

        -- Fallback logic: try other specs for the same class
        local numSpecs = GetNumSpecializationsForClassID(classId)

        for i = 1, numSpecs do
            local fallbackSpecId = GetSpecializationInfoForClassID(classId, i)
            if fallbackSpecId and fallbackSpecId ~= specId then
                self:GetTrinketData()(fallbackSpecId)
                if self.BisTrinkets then
                    -- print("Fallback successful! Loaded trinket data for specId " .. fallbackSpecId)
                    return
                end
            end
        end

        -- If no fallback was successful
        -- print("Error: Could not retrieve trinket data for any spec in this class.")
    else
        -- print("Successfully loaded trinket data for specId " .. specId)
    end
end

-- Function to update data for class and spec on event
function addon:UpdateDataForSpec()
    self:GetPlayerClassAndSpec()
    self:InitializeDataLoader()
end
