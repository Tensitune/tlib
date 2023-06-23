if not tll then return end

tll.types = {
    ["string"] = "string",
    ["number"] = "number",
    ["bool"] = "boolean",
    ["boolean"] = "boolean",
    ["table"] = "table",
    ["function"] = "function",
}

--- Validates a table against a schema.
--- Schema example:
--- * {
--- *     schemaStr = "string",
--- *     schemaFunc = "function",
--- *     schemaMultiType = { "string", "table" }
--- *     schemaCustomCheck = function(self) return isstring(self) or istable(self) end,
--- * }
function tll.CheckTableValidation(schema, validationTable, validationString)
    local stackTrace = debug.traceback()
    local stackTraceStr = stackTrace:find("in main chunk")

    stackTraceStr = string.Explode("\n\t", stackTrace:sub(1, stackTraceStr - 3))
    stackTraceStr = stackTraceStr[#stackTraceStr]

    local errorText

    if type(schema) ~= "table" then
        errorText = "[TLL Error] Schema must be a table! [" .. stackTraceStr .. "]\n"
    end
    if table.Count(schema) == 0 then
        errorText = "[TLL Error] Schema must not be empty! [" .. stackTraceStr .. "]\n"
    end
    if type(validationTable) ~= "table" then
        errorText = "[TLL Error] Validation table must be a table! [" .. stackTraceStr .. "]\n"
    end
    if table.Count(validationTable) == 0 then
        errorText = "[TLL Error] Validation table must not be empty! [" .. stackTraceStr .. "]\n"
    end

    if errorText then
        ErrorNoHalt(errorText)
        return false
    end

    local isValid = true
    errorText = ("[TLL Error] Incorrect %s! [%s]\nInvalid elements:\n"):format(validationString or "table", stackTraceStr)

    for k, v in next, validationTable do
        local schemaValue = schema[k]
        local schemaValueType = type(schemaValue)
        local schemaValueIsFunc = schemaValueType == "function"

        local schemaTypeIsValid = false

        if schemaValueType == "table" then
            if #schemaValue == 0 then
                ErrorNoHalt("[TLL Error] '" .. k .. "' types not found! [" .. stackTraceStr .. "]\n")
                return false
            end

            for i = 1, #schemaValue do
                local value = schemaValue[i]
                local schemaType = tll.types[value]

                if not schemaType then
                    ErrorNoHalt("[TLL Error] Invalid type of '" .. k .. "'! '" .. value .. "' does not exist! [" .. stackTraceStr .. "]\n")
                    return false
                end

                if type(v) == schemaType then
                    schemaTypeIsValid = true
                end
            end
        elseif schemaValueType == "string" then
            local schemaType = tll.types[schemaValue]
            if not schemaType then
                ErrorNoHalt("[TLL Error] Invalid type of '" .. k .. "'! '" .. schemaValue .. "' does not exist! [" .. stackTraceStr .. "]\n")
                return false
            end

            schemaTypeIsValid = type(v) == schemaType
        end

        if not schemaTypeIsValid and not (schemaValueIsFunc and schemaValue(validationTable[k])) then
            local schemaType = schemaValueType == "table" and "(must be a " .. tll.tableToString(schemaValue) .. ")"
                                    or schemaValueType == "function" and ""
                                    or "(must be a " .. schemaValue .. ")"

            errorText = errorText .. ("\t- %s %s\n"):format(k, schemaType)
            isValid = false
        end
    end

    if not isValid then ErrorNoHalt(errorText) end
    return isValid
end
