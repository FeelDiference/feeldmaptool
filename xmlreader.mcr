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
fn readRoomData xmlFile = (
    local xmlDoc = dotNetObject "System.Xml.XmlDocument"
    xmlDoc.load xmlFile

    -- Читаем имена комнат
    global roomNodes = xmlDoc.SelectNodes "//archetypes/Item[@type='CMloArchetypeDef']/rooms/Item"
    global roomNames = for i = 0 to roomNodes.Count-1 collect (roomNodes.item[i].SelectSingleNode("name")).InnerText

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
fn updateSceneObjects objectDataList roomIndex = (
    -- Получаем список индексов объектов для выбранной комнаты
    local indexes = objectIndexes[roomIndex]
    -- Перебираем все объекты в списке данных объектов и обновляем только те, которые есть в списке индексов
    with redraw off (
        for i = 1 to indexes.count do (
            local objectIndex = indexes[i]
            if objectIndex != undefined and objectIndex < objectDataList.count then (
                local objectData = objectDataList[objectIndex+1] -- Индексы объектов в списке данных начинаются с 0
                local objectName = objectData[1]
                local obj = getNodeByName objectName
                
                -- Проверяем, что объект найден в сцене и является геометрией
                if obj != undefined then (
                    -- Проверяем, что объект видим и обновляем его позицию и поворот
                    if obj.isHidden == false then (
                        local newPosition = [objectData[2][1], objectData[2][2], objectData[2][3]]  
                        local rotX = objectData[3][1]
                        local rotY = objectData[3][2]
                        local rotZ = objectData[3][3]
                        local newRotation = eulerangles rotX rotY rotZ
                        obj.rotation = newRotation
                        obj.pos = newPosition
                        print "Объект обновлен:"
                        print objectName
                        print "Новые координаты:"
                        print newPosition
                    ) else (
                        format ""
                    )
                ) else (
                    format "" 
                )
            ) else (
                format "" 
            )
        )
    )
    -- Выводим сообщение о завершении обновления объектов
    messagebox "Объекты были обновлены в соответствии с данными из XML файла."
    redrawViews()
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
fn startsWith s prefix =
(
    (findString s prefix) == 1
)

global moveObjectsToLayer
fn moveObjectsToLayer objects roomName =
(
    local layerName = roomName
    local layer = LayerManager.getLayerFromName layerName

    if layer == undefined then
    (
        layer = LayerManager.newLayerFromName layerName
    )

    for obj in objects do
    (
        if classOf obj == EGIMS_V_Model then
        (
            layer.addNode obj
            local childrenToCheck = for child in obj.children collect child
            while childrenToCheck.count > 0 do
            (
                local currentChild = childrenToCheck[1]
                deleteItem childrenToCheck 1
                
                layer.addNode currentChild
                
                for child in currentChild.children do
                (
                    append childrenToCheck child
                )
            )
        )
    )
)

rollout ObjectPlacer "FeelD MapTools" width:162 height:385 (
    button xmlButton "Выберите файл XML" pos:[10, 5] width:135 height:30
    dropdownList roomDropdown "Выберите комнату:" pos:[10, 40] width:135 height:20 items:#()
    button importButton "Расставить объекты" pos:[5,100] width:150 height:30
    button restoreButton "Восстановить позиции объектов" pos:[5,135] width:150 height:30 enabled:false
    button moveToLayerButton "Комнаты и их объекты в слои" pos:[5,170] width:150 height:30  enabled:false
    button exportButton "Экспорт" pos:[5,205] width:150 height:30 
    button btnHide "Скрыть игровые коллизии" pos:[5,240] width:150 height:30
    button btnShow "Показать игровые коллизии" pos:[5,275] width:150 height:30
    button btn_RunScript "Create Portal" pos:[5,310] width:150 height:30
    button btn_RunScript2 "Убрать GTAV объекты из экспорта" pos:[5,345] width:150 height:30
    

    -- Словарь для хранения позиций объектов по комнатам
    




    
    on btn_RunScript pressed do (
    -- Путь к скрипту customPortals.ms
    local appdata_path = getDir #userScripts
    local script_path = appdata_path + "\feeldmap\crtlportal.ms"

    -- Запуск скрипта
    fileIn script_path
  )

    
    on btn_RunScript2 pressed do (
    -- Путь к скрипту customPortals.ms
    local appdata_path2 = getDir #userScripts
    local script_path2 = appdata_path2 + "\feeldmap\forexport.ms"

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
            
            format "roomNames: %\n" roomNames
            format "objectIndexes: %\n" objectIndexes
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
        local objPos = xmlData[i][2] as Point3
        local sceneObj = getNodeByName objName
        if sceneObj != undefined then
        (
            append roomOriginalPositions #(sceneObj.name, sceneObj.position)
        )
    )

    if roomIndex > 0 and roomIndex <= roomOriginalPositions.count then
    (
        local roomIndexInList = roomIndex - 1
        format "Сохранены позиции объектов для комнаты %: %\n" roomIndex roomOriginalPositions -- добавлено для вывода информации
        roomOriginalPositions
    )
    else
    (
        print "Ошибка: неверный индекс комнаты"
        undefined
    )
)


fn restoreOriginalPositions originalPositionsList =
(
    if originalPositionsList != undefined then (
        for originalPos in originalPositionsList do
        (
            local objName = originalPos[1]
            local objPos = originalPos[2]
            local sceneObj = getNodeByName objName
            if sceneObj != undefined do (
                sceneObj.pos = objPos
            )
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

        local roomIndexInList = findRoomIndex originalPositionList roomIndex
        if roomIndexInList == 0 do (
            local savedPositions = saveOriginalPositions xmlData roomIndex
            append originalPositionList #(roomIndex, savedPositions)
            format "Сохраненные позиции объектов в списке: %\n" originalPositionList
            roomIndexInList = findRoomIndex originalPositionList roomIndex -- добавлено для обновления индекса комнаты в списке
        )

        updateSceneObjects xmlData roomIndex
        restoreButton.enabled = true
        moveToLayerButton.enabled = true
    )
)

on moveToLayerButton pressed do
(
    local roomIndex = ObjectPlacer.roomDropdown.selection as integer
    local roomName = roomNames[roomIndex]
    local indexes = objectIndexes[roomIndex]
    if roomName != undefined then
    (
        local objectsToMove = for i in indexes where (getNodeByName xmlData[i+1][1]) != undefined collect (getNodeByName xmlData[i+1][1])
        moveObjectsToLayer objectsToMove (roomName)
    )
    print roomNames
    print roomIndex
)

on restoreButton pressed do (
    local roomIndex = ObjectPlacer.roomDropdown.selection
    local roomIndexInList = findRoomIndex originalPositionList roomIndex

    if roomIndexInList > 0 do (
        local roomOriginalPositions = originalPositionList[roomIndexInList][2]
        format "Восстановление позиций объектов для комнаты %: %\n" roomIndex roomOriginalPositions -- добавлено для вывода информации
        restoreOriginalPositions roomOriginalPositions
        restoreButton.enabled = false
    )
)


on exportButton pressed do (
    if xmlFilePath != undefined and xmlData != undefined do (
        updateXMLData xmlFilePath xmlData xmlData
        messagebox "XML файл успешно обновлен."
    )
)

)
createDialog ObjectPlacer


)