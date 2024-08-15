local _, addon = ...

function addon:InitializeDataLoader()
    if self.game ~= "RETAIL" then
        return
    end

    local classId = self.db.char.classId
    local specIndex = self.db.char.specId
    local specId = GetSpecializationInfo(specIndex)

    if not classId or not specId then
        print("Error: classId or specId is missing.")
        return
    end

    local methodName = "LoadTrinketsForClass_" .. classId
    local method = self[methodName]

    if method and type(method) == "function" then
        method(self, specId)
    else
        print("Error: Method " .. methodName .. " not found.")
        return
    end

    if not self.BisTrinkets then
        print("Error: BisTrinkets data is not available.")
    end
end

