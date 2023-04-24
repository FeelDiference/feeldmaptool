rollout vertexSequenceRollout "Vertex Sequence" width:400 height:150
(
    -- Создаем интерфейс
    edittext vertexSequenceField "Vertex Sequence:" pos:[5, 20] width:390 height:60 readonly:true
    button resetButton "Reset" pos:[310, 90] width:80 height:40
    button createPlaneButton "Create Plane" pos:[220, 90] width:80 height:40 enabled:true
    checkbox scriptToggle "Enable Script" pos:[5, 100] checked:true
    timer vertexSelectionTimer interval:100 active:true
    -- Переменные
    local selectedVertsOrder = #()
    local lastSelectedVerts = #()
    global coordsList = #()
    
    -- Получаем выделенные индексы этих вершин
fn getSelectedVertices obj =
(
    local selectedVerts = #()
    case classOf obj of
    (
        Editable_Poly: (selectedVerts = polyop.getVertSelection obj)
        default: (format "Unsupported object type: %\n" (classOf obj))
    )
    return selectedVerts
)



-- Запоминаем порядок выделенных вершин
fn rememberSelectionOrder obj =
(
    if scriptToggle.checked and (classOf obj == Editable_Poly) do
    (
        local currentSelection = getSelectedVertices obj
        if currentSelection != undefined and currentSelection != lastSelectedVerts do
        (
            for vert in currentSelection do
            (
                if (findItem selectedVertsOrder vert) == 0 do
                (
                    append selectedVertsOrder vert
                    local coord = case classOf obj of
                    (
                        Editable_Poly: (polyop.getVert obj vert)
                        Editable_Mesh: (getVert obj vert) -- ??????????? getVert ??? Editable_Mesh
                        default: [0, 0, 0]
                    )
                    vertexSequenceField.text += (coord.x as string) + "," + (coord.y as string) + "," + (coord.z as string) + "\n"
                )
            )
            lastSelectedVerts = currentSelection
        )
    )
)


    -- Получаем координаты выделенных вершин
    fn getCoordsList text =
    (
        local coordsList = #()
        for line in (filterString text "\n") where line != "" do
        (
            try
            (
                local coordComponents = (filterString line ",")
                local coord = [coordComponents[1] as float, coordComponents[2] as float, coordComponents[3] as float]
                if coord != undefined then
                (
                    append coordsList coord
                    format "Parsed coord: %\n" coord
                )
            )
            catch
            (
                format "Error parsing line: %\n" line
            )
        )
        coordsList
    )

    -- Проверка на наличие 4 точек в координатах
    fn hasFourCoords text =
    (
        local coordsList = #()
        for line in (filterString text "\n") where line != "" do
        (
            try
            (
                local formattedLine = substituteString line "," " "
                local coord = execute ("point3 " + formattedLine)

                if coord != undefined do
                (
                    append coordsList coord
                )
            )
            catch()
        )
        return coordsList.count == 4
    )

     --Создаем плоскость по 4 выделенным координатам

fn createPlaneFromFourCoords coords =
(
    local planeP = Plane lengthsegs:1 widthsegs:1
    local quad = #{1..4}
    local verts = coords

    convertToPoly planeP
    polyOp.deleteVerts planeP quad

    for i = 1 to 4 do
    (
        local vertVec = verts[i]
        polyOp.createVert planeP vertVec
    )

    polyOp.createPolygon planeP #(4, 3, 2, 1)
    
    planeP.name = "Portal"
    planeP.wirecolor = (color 6 216 31)
    planeP.material = StandardMaterial name:"Portal_Material" diffuse:(color 6 216 31) opacity:50
    
    centerPivot planeP
    
    addModifier planeP (FFLDPortal())

    local ffdPortalMod = planeP.modifiers[#FFLDPortal]
    ffdPortalMod.vertexCorner = vertexSequenceField.text

    return planeP
)


    
     on scriptToggle changed state do
    (
        vertexSelectionTimer.active = state
    )

    -- Ресетим поле ввода
    on resetButton pressed do
    (
        selectedVertsOrder = #()
        vertexSequenceField.text = ""
    )

    -- При нажатии кнопки создать портал
    on createPlaneButton pressed do
    (
        local coordsList = getCoordsList vertexSequenceField.text
        if coordsList.count == 4 then
        (
            createPlaneFromFourCoords coordsList

            -- Выключаем таймер и скрипт
            scriptToggle.checked = false

        )
        
    )
    
    -- Создание таймера
    
    on vertexSelectionTimer tick do
    (
        if selection.count == 1 and (classOf selection[1] == Editable_Poly or classOf selection[1] == Editable_Mesh) do
        (
            rememberSelectionOrder selection[1]
            createPlaneButton.enabled = hasFourCoords vertexSequenceField.text
        )
        
    )
    
)

createDialog vertexSequenceRollout
