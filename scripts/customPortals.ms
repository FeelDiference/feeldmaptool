  -- Получаем список выделенных объектов
  selObj = selection as array

  -- Если объекты выделены, то обрабатываем каждый из них
  if selObj.count > 0 then
  (
    for obj in selObj do
    (
      -- Проверяем, что объект можно сконвертировать в Editable Poly
      if canConvertTo obj Editable_Poly do
      (
        -- Конвертируем объект в Editable Poly
        convertTo obj Editable_Poly
        -- Получаем список вершин объекта
        vertList = #()
        numVerts = obj.numVerts

        -- Проверяем, что количество вершин не превышает 4
        if numVerts == 4 then
        (
          for j = 1 to numVerts do
          (
            vert = polyOp.getVert obj j
            append vertList vert
          )

          -- Выводим координаты каждой вершины в консоль
          format "%, %, %\n" vertList[1].x vertList[1].y vertList[1].z
          format "%, %, %\n" vertList[3].x vertList[3].y vertList[3].z
          format "%, %, %\n" vertList[4].x vertList[4].y vertList[4].z
          format "%, %, %\n" vertList[2].x vertList[2].y vertList[2].z

          -- Копируем вывод в буфер обмена
          setClipboardText ((vertList[1].x as string) + "," + (vertList[1].y as string) + "," + (vertList[1].z as string) + "\n" +
                            (vertList[3].x as string) + "," + (vertList[3].y as string) + "," + (vertList[3].z as string) + "\n" +
                            (vertList[4].x as string) + "," + (vertList[4].y as string) + "," + (vertList[4].z as string) + "\n" +
                            (vertList[2].x as string) + "," + (vertList[2].y as string) + "," + (vertList[2].z as string))
        )
        else
        (
          -- Выводим всплывающее окно с сообщением о количестве вершин
          messageBox "Количество вершин должно быть равным 4." title:"Ошибка"
        )
      )
    )
  )
  else
  (
    -- Выводим всплывающее окно с сообщением об ошибке
    messageBox "Не выбран ни один объект." title:"Ошибка"
  )

