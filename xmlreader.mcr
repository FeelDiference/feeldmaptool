macroScript ObjectPlacer
category: "Custom Portals by FeelD"
tooltip: "Object Placer"
(
fn quaternionToEulerAngles q = (
    local rotMat = q as matrix3
    local rx = atan2 (rotMat.row3[2]) (rotMat.row3[3])
    local ry = -asin (rotMat.row3[1])
    local rz = atan2 (rotMat.row2[1]) (rotMat.row1[1])
    [rx, ry, rz] as point3
)

local xmlFilePath = undefined
local objectIndexes = undefined
fn trimString str = 
(
    if str != "" then
    (
        (dotNetObject "System.String" str).Trim()

    )
    else ""
)
fn readEntityNode entityNode = (
    local objectName = (entityNode.SelectSingleNode("archetypeName")).InnerText
    local positionNode = entityNode.SelectSingleNode("position")
    local positionX = (positionNode.GetAttribute("x") as float)
    local positionY = (positionNode.GetAttribute("y") as float)
    local positionZ = (positionNode.GetAttribute("z") as float)
    local rotationNode = entityNode.SelectSingleNode("rotation")
    local rotationX = (rotationNode.GetAttribute("x") as float)
    local rotationY = (rotationNode.GetAttribute("y") as float)
    local rotationZ = (rotationNode.GetAttribute("z") as float)
    local rotationW = (rotationNode.GetAttribute("w") as float)
    local quaternion = quat 0 0 0 1 -- Создаем пустой кватернион
    quaternion.x = rotationX
    quaternion.y = rotationY
    quaternion.z = rotationZ
    quaternion.w = rotationW
    if quaternion != undefined then (
        local rotation = quaternionToEulerAngles quaternion
        local objectData = #(objectName, [positionX, positionY, positionZ], rotation)
        return objectData
    ) else (
        format "Quaternion is undefined for object %.\n" objectName
        return undefined
    )
)
fn readRoomData xmlFile = (
    local xmlDoc = dotNetObject "System.Xml.XmlDocument"
    xmlDoc.load xmlFile

    -- Читаем имена комнат
    local roomNodes = xmlDoc.SelectNodes "//archetypes/Item/rooms/Item"
    local roomNames = for i = 0 to roomNodes.Count-1 collect (roomNodes.item[i].SelectSingleNode("name")).InnerText

    -- Читаем индексы объектов для каждой комнаты
    local objectIndexesList = for i = 0 to roomNodes.Count-1 collect (
        local attachedObjectsNode = roomNodes.item[i].SelectSingleNode("attachedObjects[@content='int_array']")
        if attachedObjectsNode != undefined then (
            local indexArray = trimString(attachedObjectsNode.InnerText as string)
            local indexStrings = filterString indexArray "\n"
            local trimmedIndexStrings = for j = 1 to indexStrings.count collect (trimString indexStrings[j]) -- use for loop instead of map
            format "Строки индексов для комнаты %: %\n" (i+1) trimmedIndexStrings
            local indexes = for k = 1 to trimmedIndexStrings.count where trimmedIndexStrings[k] != "" collect (trimmedIndexStrings[k] as integer)
            format "Список индексов для комнаты %: %\n" (i+1) indexes
            indexes
        ) else (
            #()
        )
    )
    -- Выводим отладочную информацию
    print  "Имена комнат:"
    print roomNames
    print "Индексы объектов:"
    print objectIndexesList

    -- Возвращаем имена комнат и список индексов объектов для каждой комнаты
    #(roomNames, objectIndexesList)
)
-- Создаем функцию для открытия диалогового окна выбора файла
fn getXMLFile = (
    -- Создаем диалоговое окно для выбора файла
    local xmlFile = getOpenFileName \
        caption:"Выберите XML файл" \
        types:"XML Files (*.xml)|*.xml|All Files (*.*)|*.*||"
    
    -- Возвращаем выбранный файл
    return xmlFile
)

-- Создаем функцию для чтения данных из файла
fn readXMLData xmlFile = (
    local xmlDoc = dotNetObject "System.Xml.XmlDocument"
    xmlDoc.load xmlFile

    -- Читаем узлы с тегом "Item" из секции "entities"
    local entityNodes = xmlDoc.SelectNodes("//entities/Item")
    local objectDataList = for i = 0 to entityNodes.Count-1 collect (
        local objectName = (entityNodes.item[i].SelectSingleNode("archetypeName")).InnerText
        local positionNode = entityNodes.item[i].SelectSingleNode("position")
        local positionX = (positionNode.GetAttribute("x") as float)
        local positionY = (positionNode.GetAttribute("y") as float)
        local positionZ = (positionNode.GetAttribute("z") as float)
        local rotationNode = entityNodes.item[i].SelectSingleNode("rotation")
        local rotationX = (rotationNode.GetAttribute("x") as float)
        local rotationY = (rotationNode.GetAttribute("y") as float)
        local rotationZ = (rotationNode.GetAttribute("z") as float)
        local rotationW = (rotationNode.GetAttribute("w") as float)
        local quaternion = quat 0 0 0 1
        quaternion.x = rotationX
        quaternion.y = rotationY
        quaternion.z = rotationZ
        quaternion.w = rotationW
        if quaternion != undefined then (
            local rotation = quaternionToEulerAngles quaternion
            #(objectName, [positionX, positionY, positionZ], rotation)
        ) else (
            format "Quaternion is undefined for object %.\n" objectName
            undefined
        )
    )
    if objectDataList != undefined then (
        format "Прочитано % объектов из XML файла.\n" objectDataList.count
    )
    objectDataList
)
fn updateSceneObjects xmlData roomIndex =
(
    for i = 1 to xmlData.count do
    (
        local objName = xmlData[i][1]
        local objPosData = xmlData[i][2]
        local objRotData = xmlData[i][3]
        local sceneObj = getNodeByName objName

        if sceneObj != undefined then
        (
            if sceneObj.isHidden == false then
            (
                local objPos = [((objPosData[1]) as float), ((objPosData[2]) as float), ((objPosData[3]) as float)]
                local objRot = (eulerAngles ((objRotData[1]) as float) ((objRotData[2]) as float) ((objRotData[3]) as float))
                sceneObj.pos = objPos
                sceneObj.rotation = objRot
            )
            else
            (
                format "Object % is hidden in the scene.\n" objName
            )
        )
        else
        (
            format "Object % not found in the scene.\n" objName
        )
    )
)

fn setVisibilityByClass className isVisible =
(
    allObjects = objects as array

    for obj in allObjects do
    (
        if (classOf obj) == className then
        (
            obj.isHidden = not isVisible
        )
    )
)

-- Определение классов
class1 = EGIMS_V_Col_Composite
class2 = EGIMS_V_CollisionMesh
class3 = EGIMS_V_Col_Box
class4 = EGIMS_V_Col_Cylinder

rollout ObjectPlacer "FeelD MapTools" width:162 height:350 (
    button xmlButton "Выберите файл XML" pos:[10, 5] width:135 height:30
    dropdownList roomDropdown "Выберите комнату:" pos:[10, 40] width:135 height:20 items:#()
    button importButton "Расставить объекты" pos:[5,100] width:150 height:30
    button restoreButton "Восстановить позиции объектов" pos:[5,135] width:150 height:30 enabled:false
    button exportButton "Экспорт" pos:[5,170] width:150 height:30 enabled:false
	button btnHide "Скрыть игровые коллизии" pos:[5,205] width:150 height:30
	button btnShow "Показать игровые коллизии" pos:[5,240] width:150 height:30
	button btn_RunScript "Create Portal" pos:[5,275] width:150 height:30
	button btn_RunScript2 "Убрать GTAV объекты из экспорта" pos:[5,310] width:150 height:30
    -- Словарь для хранения позиций объектов по комнатам
	

	
	on btn_RunScript pressed do (
    -- Путь к скрипту customPortals.ms
	local appdata_path = getDir #userScripts
	local script_path = appdata_path + "\customPortals.ms"

    -- Запуск скрипта
    fileIn script_path
  )

	
	on btn_RunScript2 pressed do (
    -- Путь к скрипту customPortals.ms
	local appdata_path2 = getDir #userScripts
	local script_path2 = appdata_path2 + "\forexport.ms"

    -- Запуск скрипта
    fileIn script_path2
  )
  
  on btnHide pressed do
    (
        setVisibilityByClass class1 false
        setVisibilityByClass class2 false
		setVisibilityByClass class3 false
		setVisibilityByClass class4 false
    )

    on btnShow pressed do
    (
        setVisibilityByClass class1 true
        setVisibilityByClass class2 true
		setVisibilityByClass class3 true
		setVisibilityByClass class4 true
    )

    on xmlButton pressed do (
        xmlFilePath = getXMLFile()
        if xmlFilePath != undefined do (
            local roomData = readRoomData xmlFilePath
            ObjectPlacer.roomDropdown.items = roomData[1]
            objectIndexes = roomData[2]
            ObjectPlacer.roomDropdown.selection = 1
			
			global xmlData = readXMLData xmlFilePath
        )
    )

    on ObjectPlacer.roomDropdown.selectionChanged val do (
        local xmlFile = xmlFilePath
        if xmlFile != undefined do (
            local roomIndex = ObjectPlacer.roomDropdown.selection
            updateSceneObjects xmlFile roomIndex
        )
    )
	local originalPositionList = #()
	local objectsList = #()
-- Инициализируем словарь для хранения оригинальных позиций объектов
fn saveOriginalPositions xmlData roomIndex =
(
    local roomOriginalPositions = #()
    for i = 1 to xmlData.count do
    (
        local objName = xmlData[i][1]
        local sceneObj = getNodeByName objName
        if sceneObj != undefined do (
            local objPos = sceneObj.pos
			append roomOriginalPositions [objName, objPos as string]
        )
    )
    
    return #(roomIndex, roomOriginalPositions)
)



fn restoreOriginalPositions originalPositionsList =
(
    if originalPositionsList != undefined then (
        for originalPos in originalPositionsList where isKindOf originalPos Array do
        (
            local objName = originalPos[1]
            local objPos = originalPos[2]
            local sceneObj = getNodeByName objName
            if sceneObj != undefined do sceneObj.pos = [objPos[1] as float, objPos[2] as float, objPos[3] as float]
        )
    )
)




fn findRoomIndex list roomIndex =
(
    for i = 1 to list.count do
    (
        if list[i][1] == roomIndex then
        (
            return i
        )
    )
    return 0
)




on importButton pressed do (
    if xmlData != undefined do (
        local roomIndex = ObjectPlacer.roomDropdown.selection

        -- Проверяем, есть ли уже сохраненные позиции для данной комнаты
        if findRoomIndex originalPositionList roomIndex == 0 do (
            append originalPositionList (saveOriginalPositions xmlData roomIndex)
        )

        updateSceneObjects xmlData roomIndex

        -- Error handling for restoreButton
        if isKindOf restoreButton RolloutControl then (
            restoreButton.enabled = true
        ) else (
            format "Error: restoreButton is not a valid RolloutControl.\n"
        )
    )
)


on restoreButton pressed do (
    local roomIndex = ObjectPlacer.roomDropdown.selection
    format "roomIndex: %\n" roomIndex

    local roomIndexInList = findRoomIndex originalPositionList roomIndex
    format "roomIndexInList: %\n" roomIndexInList

    if roomIndexInList > 0 do (
        local roomOriginalPositions = originalPositionList[roomIndexInList][2]
        format "roomOriginalPositions: %\n" roomOriginalPositions
        
        restoreOriginalPositions roomOriginalPositions

        -- Error handling for restoreButton
        if isKindOf restoreButton RolloutControl then (
            restoreButton.enabled = false
        ) else (
            format "Error: restoreButton is not a valid RolloutControl.\n"
        )
    )
)




)

createDialog ObjectPlacer


)