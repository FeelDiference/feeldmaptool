plugin modifier FFLDPortal
name:"FFLDPortal"
classID:#(0x5a8397b1, 0x3c4b10f2)
extends:EmptyModifier
    (
    -- Создание параметров модификатора
        parameters main rollout:params
        (
            -- Определение параметров модификатора
            roomFrom type:#string ui:edtRoomFrom default:"1"
            roomTo type:#string ui:edtRoomTo default:"0"
            chk1 type:#boolean ui:chk1
            chk2 type:#boolean ui:chk2
            chk3 type:#boolean ui:chk3
            chk4 type:#boolean ui:chk4
            chk5 type:#boolean ui:chk5
            chk6 type:#boolean ui:chk6
            chk7 type:#boolean ui:chk7
            chk8 type:#boolean ui:chk8
            chk9 type:#boolean ui:chk9
            chk10 type:#boolean ui:chk10
            chk11 type:#boolean ui:chk11
            chk12 type:#boolean ui:chk12
            chk13 type:#boolean ui:chk13
            chk14 type:#boolean ui:chk14
            vertexCorner type:#string ui:edtvertexCorner default:""
             
        )
    -- Создание пользовательского интерфейса
    rollout params "FFLDPortal Parameters"
    (
        -- Создание текстовых полей "Room From" и "Room To"
        editText edtRoomFrom "Room From:" align:#right fieldWidth:50
        editText edtRoomTo "Room To:" align:#right fieldWidth:50
        editText mirpri "Mirror Priority:" align:#right fieldWidth:50 
        editText opac "Opacity:" align:#right fieldWidth:50 
        editText audoccl "Audio Occlusion:" align:#right fieldWidth:50
        -- Создание текстового блока и чекбоксов
        label lblTotal "Total Value: 0" align:#left
        checkBox chk1 "1 - Disables exterior rendering" align:#left
        checkBox chk2 "2 - Disables interior rendering" align:#left
        checkBox chk3 "4 - Mirror" align:#left
        checkBox chk4 "8 - Extra Bloom" align:#left
        checkBox chk5 "16 - Unk05" align:#left
        checkBox chk6 "32 - Use exterior LOD" align:#left
        checkBox chk7 "64 - Hide when door closed" align:#left
        checkBox chk8 "128 - Unk08" align:#left
        checkBox chk9 "256 - Mirror exterior portals" align:#left
        checkBox chk10 "512 - Unk10" align:#left
        checkBox chk11 "1024 - Mirror limbo entities" align:#left
        checkBox chk12 "2048 - Unk12" align:#left
        checkBox chk13 "4096 - Unk13" align:#leftw
        checkBox chk14 "8192 - Disable farclipping" align:#left
        label vertCorn "Corners" align:#center
        editText edtvertexCorner align:#center height:80 width:160 readonly:true
        
               -- Функция расчета итогового значения
        fn updateTotal =
        (
            local total = 0

            if chk1.state then total += 1
            if chk2.state then total += 2
            if chk3.state then total += 4
            if chk4.state then total += 8
            if chk5.state then total += 16
            if chk6.state then total += 32
            if chk7.state then total += 64
            if chk8.state then total += 128
            if chk9.state then total += 256
            if chk10.state then total += 512
            if chk11.state then total += 1024
            if chk12.state then total += 2048
            if chk13.state then total += 4096
            if chk14.state then total += 8192
            lblTotal.text = "Total Value: " + total as string
        )
        fn getSaveData = #(edtRoomFrom.text, edtRoomTo.text,
            chk1.state, chk2.state, chk3.state, chk4.state,
            chk5.state, chk6.state, chk7.state, chk8.state,
            chk9.state, chk10.state, chk11.state, chk12.state, chk13.state, chk14.state, lblTotal.text,edtvertexCorner.text)
        fn setSaveData arr = (
            edtRoomFrom.text = arr[1]
            edtRoomTo.text = arr[2]
            chk1.state = arr[3]
            chk2.state = arr[4]
            chk3.state = arr[5]
            chk4.state = arr[6]
            chk5.state = arr[7]
            chk6.state = arr[8]
            chk7.state = arr[9]
            chk8.state = arr[10]
            chk9.state = arr[11]
            chk10.state = arr[12]
            chk11.state = arr[13]
            chk12.state = arr[14]
            chk13.state = arr[15]
            chk14.state = arr[16]
            lblTotal.text = arr[17]
            edtvertexCorner.text = arr[18]
        )
        -- Привязка функции к событиям изменения состояния чекбоксов
        on chk1 changed state do updateTotal()
        on chk2 changed state do updateTotal()
        on chk3 changed state do updateTotal()
        on chk4 changed state do updateTotal()
        on chk5 changed state do updateTotal()
        on chk6 changed state do updateTotal()
        on chk7 changed state do updateTotal()
        on chk8 changed state do updateTotal()
        on chk9 changed state do updateTotal()
        on chk10 changed state do updateTotal()
        on chk11 changed state do updateTotal()
        on chk12 changed state do updateTotal()
        on chk13 changed state do updateTotal()
        on chk14 changed state do updateTotal()
        on edtRoomFrom entered text do
        (
             roomFrom = text
        )
        
        on edtRoomTo entered text do
        (
            roomTo = text
        )
         on edtvertexCorner entered text do
        (
            vertexCorner = text
        )
        on params open do
        (
            edtRoomFrom.text = roomFrom
            edtRoomTo.text = roomTo
            edtvertexCorner.text = vertexCorner
            updateTotal()
        )
        
    )
    

     -- Создание пользовательских атрибутов
    on FFLDPortal open do
    (
        replaceUI params
        -- Добавление кастомных атрибутов к модификатору
        custAttributes.add this FFLDPortalAttributes
    )

)