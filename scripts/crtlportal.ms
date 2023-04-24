rollout vertexSequenceRollout "Vertex Sequence" width:400 height:150
(
    -- ???????? ????????????????? ??????????
    edittext vertexSequenceField "Vertex Sequence:" pos:[5, 20] width:390 height:60 readonly:true
    button resetButton "Reset" pos:[310, 90] width:80 height:40
    button createPlaneButton "Create Plane" pos:[220, 90] width:80 height:40 enabled:true
    checkbox scriptToggle "Enable Script" pos:[5, 100] checked:true

    -- ????????? ??????????
    local selectedVertsOrder = #()
    local lastSelectedVerts = #()
    global coordsList = #()

    -- ??????? ??? ??????????? ????????? ??????
    fn getSelectedVertices obj =
    (
        local selectedVerts = #()
        case classOf obj of
        (
            Editable_Poly: (selectedVerts = polyop.getVertSelection obj)
            Editable_Mesh: (selectedVerts = meshop.getVertSelection obj)
            default: (format "Unsupported object type: %\n" (classOf obj))
        )
        return selectedVerts
    )

    -- ??????? ??? ??????????? ?????????????????? ?????? ??????
    fn rememberSelectionOrder obj =
    (
        if scriptToggle.checked do
        (
            local currentSelection = getSelectedVertices obj
            if currentSelection != lastSelectedVerts do
            (
                for vert in currentSelection do
                (
                    if (findItem selectedVertsOrder vert) == 0 do
                    (
                        append selectedVertsOrder vert
                        local coord = case classOf obj of
                        (
                            Editable_Poly: (polyop.getVert obj vert)
                            Editable_Mesh: (meshop.getVert obj vert)
                            default: [0, 0, 0]
                        )
                        vertexSequenceField.text += (coord.x as string) + "," + (coord.y as string) + "," + (coord.z as string) + "\n"
                    )
                )
                lastSelectedVerts = currentSelection
            )
        )
    )

    -- ??????? ??? ????????? ?????? ????????? ?? ?????????? ????
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

    -- ??????? ??? ???????? ??????? 4 ????????? ? ????????? ????
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

     -- ??????? ??? ???????? ????????? ?? 4 ??????
       -- ??????? ??? ???????? ????????? ?? 4 ??????
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

        polyOp.createPolygon planeP #(1, 2, 3, 4)

        -- ?????????? ???, ???? ? ????????????
        planeP.name = "Portal"
        planeP.wirecolor = (color 6 216 31)
        planeP.material = StandardMaterial name:"Portal_Material" diffuse:(color 6 216 31) opacity:50

        -- ????????? Pivot ?? ??????
        centerPivot planeP

        -- ???????? ??????????? FFD 2x2x2
        addModifier planeP (FFLDPortal())

        return planeP
    )
	timer vertexSelectionTimer interval:100 active:true
	
    -- ???????? ??? ??????? ?????? ??????
    on resetButton pressed do
    (
        selectedVertsOrder = #()
        vertexSequenceField.text = ""
    )

    -- ???????? ??? ??????? ?????? ???????? ?????????
    on createPlaneButton pressed do
    (
        local coordsList = getCoordsList vertexSequenceField.text
        if coordsList.count == 4 then
        (
            createPlaneFromFourCoords coordsList

            -- ????????? ?????? ????? ???????? ?????????
            scriptToggle.checked = false
			vertexSelectionTimer.active = false

        )
		
    )
	
    -- ?????? ??? ????????????? ???????? ?????? ??????
    
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
