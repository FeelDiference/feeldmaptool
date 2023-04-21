-- Function to check for the existence of a helper named NotForExport and create it if it doesn't exist
fn checkOrCreateNotForExportHelper =
(
    local notForExport = getNodeByName "NotForExport"

    if notForExport == undefined do
    (
        notForExport = dummy name:"NotForExport"
    )

    return notForExport
)

-- Function to move objects and their children into the structure of the specified Dummy
fn moveObjectsToDummy parentDummy objectsToMove =
(
    for obj in objectsToMove do
    (
        obj.parent = parentDummy
    )
)

-- Function to read the list of objects from an external file
fn readObjectsListFromFile filePath =
(
    local objectsList = #()

    if doesFileExist filePath do
    (
        local file = openFile filePath mode:"rt"

        while not eof file do
        (
            local objectName = trimRight (readLine file) -- Remove any trailing spaces if present
            if objectName != "" do -- Check if the line is not empty
            (
                local object = getNodeByName objectName

                if object != undefined do
                (
                    append objectsList object
                )
            )
        )

        close file
    )

    return objectsList
)

-- Main script part
(
    local notForExportDummy = checkOrCreateNotForExportHelper()
    local userScriptsPath = getDir #userScripts
    local filePath = userScriptsPath + "\\ObjectList.ini" -- or "\\objects_list.txt"

    local objectsToMove = readObjectsListFromFile filePath

    if objectsToMove.count > 0 then -- Check if the list of objects is not empty
    (
        moveObjectsToDummy notForExportDummy objectsToMove
    )
    else
    (
        messageBox "No objects found in the objects_list file or all objects are missing in the scene. Check the file and try again."
    )
)
