<%
Function KiemTraHanMucGiaPha(ByRef curTotal, ByRef maxQuota)
    curTotal = 0
    maxQuota = 100
    KiemTraHanMucGiaPha = True

    ' Kiểm tra nếu biến conn chưa tồn tại thì thoát an toàn, không báo lỗi
    If Not IsObject(conn) Then Exit Function
    If conn Is Nothing Then Exit Function

    Dim rsQuota, sql
    sql = "SELECT " & _
          "  (SELECT COUNT(*) FROM tblgiapha) AS TongHienTai, " & _
          "  ISNULL((SELECT TOP 1 gioihan_dinh FROM tblconfig), 200) AS GioiHan"
    
    On Error Resume Next
    Set rsQuota = conn.Execute(sql)
    If Err.Number = 0 And Not rsQuota.EOF Then
        curTotal = rsQuota("TongHienTai")
        maxQuota = rsQuota("GioiHan")
        
        If maxQuota > 0 And curTotal >= maxQuota Then
            KiemTraHanMucGiaPha = False
        Else
            KiemTraHanMucGiaPha = True
        End If
        rsQuota.Close
        Set rsQuota = Nothing
    End If
    On Error GoTo 0
End Function

Function GetText(keyName, defaultText)
    If uiText.Exists(keyName) Then
        GetText = uiText(keyName)
    Else
        GetText = defaultText
    End If
End Function

Function SafePermissionID(ByVal rawValue)
    Dim rawText, numericValue, integerValue
    SafePermissionID = 0

    If IsNull(rawValue) Or IsEmpty(rawValue) Then Exit Function

    rawText = Trim(CStr(rawValue))
    If rawText = "" Or Not IsNumeric(rawText) Then Exit Function

    On Error Resume Next
    numericValue = CDbl(rawText)
    integerValue = CLng(rawText)
    If Err.Number <> 0 Then
        Err.Clear
        On Error GoTo 0
        Exit Function
    End If
    On Error GoTo 0

    If integerValue <= 0 Then Exit Function
    If CDbl(integerValue) <> numericValue Then Exit Function

    SafePermissionID = integerValue
End Function

Function GetGenealogyCsrfToken()
    If Session("genealogy_csrf_token") = "" Then
        Randomize
        Session("genealogy_csrf_token") = CStr(Session.SessionID) & "-" & Replace(CStr(Timer), ",", "") & "-" & CStr(Int(Rnd() * 1000000))
    End If

    GetGenealogyCsrfToken = CStr(Session("genealogy_csrf_token"))
End Function

Function CheckGenealogyPermission(idadmin_val, target_id)
    ' Nếu là Super Admin thì có toàn quyền
    If CInt("0" & Session("is_super")) = 1 Then
        CheckGenealogyPermission = True
        Exit Function
    End If

    Dim root_id
    root_id = CInt("0" & Session("allowed_start_idgiapha"))
    
    ' Nếu không giới hạn nhánh (root_id = 0) thì cho phép
    If root_id = 0 Then
        CheckGenealogyPermission = True
        Exit Function
    End If

    ' Nếu nhân vật cần kiểm tra chính là nút gốc được phân quyền -> Hợp lệ
    If CInt(target_id) = root_id Then
        CheckGenealogyPermission = True
        Exit Function
    End If

    ' Truy ngược từ nhân vật hiện tại lên cha mẹ để xem có chạm tới nút gốc được phân quyền không
    Dim currentId, rsP, hasParent
    currentId = CInt(target_id)
    hasParent = True
    
    Do While hasParent And currentId > 0
        If currentId = root_id Then
            CheckGenealogyPermission = True
            Exit Function
        End If
        
        openconn
        Set rsP = conn.Execute("SELECT idcha FROM tblgiapha WHERE idgiapha = " & currentId)
        If Not rsP.EOF Then
            If IsNull(rsP("idcha")) Or CInt("0" & rsP("idcha")) = 0 Then
                hasParent = False
            Else
                currentId = CInt(rsP("idcha"))
            End If
        Else
            hasParent = False
        End If
        rsP.Close : Set rsP = Nothing
        destroyconn
    Loop

    ' Nếu duyệt ngược lên mà không chạm gốc phân quyền -> Từ chối
    CheckGenealogyPermission = False
End Function

Function CheckGenealogyPermissionOnConnection(connObj, admin_id, target_id)
    Dim rsPerm, rsTarget, startId, allowed, targetIdChecked
    Dim isSuper, isGenealogy, relationType, spouseOwnerID
    allowed = False

    If SafePermissionID(admin_id) = 0 Or SafePermissionID(target_id) = 0 Then
        CheckGenealogyPermissionOnConnection = False
        Exit Function
    End If

    Set rsPerm = connObj.Execute("SELECT is_super, is_genealogy, allowed_start_idgiapha FROM tbladmin WITH (UPDLOCK, HOLDLOCK) WHERE idadmin = " & SafePermissionID(admin_id))
    If Not rsPerm.EOF Then
        isSuper = SafePermissionID(rsPerm("is_super"))
        isGenealogy = SafePermissionID(rsPerm("is_genealogy"))
        startId = SafePermissionID(rsPerm("allowed_start_idgiapha"))

        If isSuper = 1 Or isGenealogy = 1 Then
            targetIdChecked = SafePermissionID(target_id)
            Set rsTarget = connObj.Execute("SELECT idcha, loai_quanhe, id_vochong FROM tblgiapha WITH (UPDLOCK, HOLDLOCK) WHERE idgiapha = " & targetIdChecked)

            If Not rsTarget.EOF Then
                relationType = SafePermissionID(rsTarget("loai_quanhe"))
                spouseOwnerID = SafePermissionID(rsTarget("id_vochong"))

                If relationType = 2 And spouseOwnerID > 0 Then
                    targetIdChecked = spouseOwnerID
                End If

                If isSuper = 1 Or startId = 0 Then
                    allowed = True
                Else
                    allowed = IsDescendant(connObj, startId, targetIdChecked)
                End If
            End If

            rsTarget.Close
            Set rsTarget = Nothing
        End If
    End If

    rsPerm.Close
    Set rsPerm = Nothing
    CheckGenealogyPermissionOnConnection = allowed
End Function

' Đi ngược từ nhân vật đích lên tổ tiên để kiểm tra phạm vi nhánh.
Function IsDescendant(connObj, rootId, targetId)
    Dim currentID, rsParent, visitedIDs, found
    found = False
    currentID = SafePermissionID(targetId)
    Set visitedIDs = CreateObject("Scripting.Dictionary")

    Do While currentID > 0
        If currentID = SafePermissionID(rootId) Then
            found = True
            Exit Do
        End If

        If visitedIDs.Exists(CStr(currentID)) Then Exit Do
        visitedIDs.Add CStr(currentID), True

        Set rsParent = connObj.Execute("SELECT idcha FROM tblgiapha WITH (UPDLOCK, HOLDLOCK) WHERE idgiapha = " & currentID)
        If rsParent.EOF Then
            currentID = 0
        Else
            currentID = SafePermissionID(rsParent("idcha"))
        End If
        rsParent.Close
        Set rsParent = Nothing
    Loop

    Set visitedIDs = Nothing
    IsDescendant = found
End Function
Function ToRoman(ByVal num)
    Dim vals, roms, res, i
    vals = Array(1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1)
    roms = Array("M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I")
    res = ""
    For i = 0 To UBound(vals)
        Do While num >= vals(i)
            res = res & roms(i)
            num = num - vals(i)
        Loop
    Next
    ToRoman = res
End Function
Function Convertbcn(Titolo)
	Risultato = Titolo
	Risultato = Replace(Risultato, "&", "/")
	Convertbcn = Risultato
End Function

Function ConvertiTitoloInNomeScript(Titolo)
	Risultato = Titolo
	Risultato = NoHTML(Risultato)
	Risultato = LCase(Risultato)
	Risultato = Replace(Risultato, "-", "_")
	Risultato = Replace(Risultato, " ", "-")
	Risultato = Replace(Risultato, "&", "va")
	Risultato = Replace(Risultato, "\", "-")
	Risultato = Replace(Risultato, "/", "-")
	Risultato = Replace(Risultato, ":", "-")
	Risultato = Replace(Risultato, "*", "-")
	Risultato = Replace(Risultato, "?", "-")
	Risultato = Replace(Risultato, "<", "-")
	Risultato = Replace(Risultato, ">", "-")
	Risultato = Replace(Risultato, "|", "-")
	Risultato = Replace(Risultato, """", "")
	Risultato = Replace(Risultato, "'", "-")
	Risultato = Replace(Risultato, "â", "a")
	Risultato = Replace(Risultato, "ầ", "a")
	Risultato = Replace(Risultato, "ấ", "a")
	Risultato = Replace(Risultato, "ậ", "a")
	Risultato = Replace(Risultato, "ẩ", "a")
	Risultato = Replace(Risultato, "ẫ", "a")
	Risultato = Replace(Risultato, "ă", "a")
	Risultato = Replace(Risultato, "ắ", "a")
	Risultato = Replace(Risultato, "ặ", "a")
	Risultato = Replace(Risultato, "ằ", "a")
	Risultato = Replace(Risultato, "ẵ", "a")
	Risultato = Replace(Risultato, "ẳ", "a")
	Risultato = Replace(Risultato, "à", "a")
	Risultato = Replace(Risultato, "ạ", "a")	
	Risultato = Replace(Risultato, "ả", "a")
	Risultato = Replace(Risultato, "á", "a")
	Risultato = Replace(Risultato, "ã", "a")
	Risultato = Replace(Risultato, "đ", "d")
	Risultato = Replace(Risultato, "ê", "e")
	Risultato = Replace(Risultato, "é", "e")
	Risultato = Replace(Risultato, "ế", "e")
	Risultato = Replace(Risultato, "ề", "e")
	Risultato = Replace(Risultato, "ệ", "e")
	Risultato = Replace(Risultato, "ễ", "e")
	Risultato = Replace(Risultato, "ể", "e")
	Risultato = Replace(Risultato, "è", "e")
	Risultato = Replace(Risultato, "ẹ", "e")
	Risultato = Replace(Risultato, "ẻ", "e")
	Risultato = Replace(Risultato, "ẽ", "e")
	Risultato = Replace(Risultato, "í", "i")
	Risultato = Replace(Risultato, "ì", "i")
	Risultato = Replace(Risultato, "ỉ", "i")
	Risultato = Replace(Risultato, "ĩ", "i")
	Risultato = Replace(Risultato, "ị", "i")
	Risultato = Replace(Risultato, "ồ", "o")
	Risultato = Replace(Risultato, "ộ", "o")	
	Risultato = Replace(Risultato, "ô", "o")
	Risultato = Replace(Risultato, "ó", "o")
	Risultato = Replace(Risultato, "ổ", "o")
	Risultato = Replace(Risultato, "ộ", "o")		
	Risultato = Replace(Risultato, "ơ", "o")	
	Risultato = Replace(Risultato, "ở", "o")	
	Risultato = Replace(Risultato, "ợ", "o")	
	Risultato = Replace(Risultato, "ỡ", "o")
	Risultato = Replace(Risultato, "õ", "o")
	Risultato = Replace(Risultato, "ờ", "o")
	Risultato = Replace(Risultato, "ớ", "o")
	Risultato = Replace(Risultato, "ọ", "o")
	Risultato = Replace(Risultato, "ố", "o")
	Risultato = Replace(Risultato, "ò", "o")
	Risultato = Replace(Risultato, "ú", "u")	
	Risultato = Replace(Risultato, "ụ", "u")
	Risultato = Replace(Risultato, "ủ", "u")
	Risultato = Replace(Risultato, "ư", "u")
	Risultato = Replace(Risultato, "ù", "u")
	Risultato = Replace(Risultato, "ừ", "u")
	Risultato = Replace(Risultato, "ứ", "u")
	Risultato = Replace(Risultato, "ử", "u")
	Risultato = Replace(Risultato, "ự", "u")
	Risultato = Replace(Risultato, "ữ", "u")
	Risultato = Replace(Risultato, "ũ", "u")
	Risultato = Replace(Risultato, "ỷ", "y")
	Risultato = Replace(Risultato, "ỵ", "y")
	Risultato = Replace(Risultato, "ỹ", "y")
	Risultato = Replace(Risultato, "ý", "y")
	Risultato = Replace(Risultato, "ỳ", "y")
	Risultato = Replace(Risultato, "'", "-")
	Risultato = Replace(Risultato, "!", "-")	
	Risultato = Replace(Risultato, "@", "-")
	Risultato = Replace(Risultato, "$", "-")
	Risultato = Replace(Risultato, "^", "-")
	Risultato = Replace(Risultato, "#", "-")
	Risultato = Replace(Risultato, "%", "-")
	Risultato = Replace(Risultato, ".", "-")
	Risultato = Replace(Risultato, ",", "-")
	Risultato = Replace(Risultato, ";", "-")

	ConvertiTitoloInNomeScript = Risultato
End Function

Function NoHTML(Stringa)
 Set RegEx = New RegExp
 RegEx.Pattern = "<[^>]*>"
 RegEx.Global = True
 RegEx.IgnoreCase = True
 NoHTML = RegEx.Replace(Stringa, "")
End Function

Private Function TrimString(strInputString, intStringLength)

	Dim intTrimLentgh

	'Trim the string down
	strInputString = Trim(strInputString) & " "

	'If the length of the text is longer than the max then cut it and place '...' at the end
	If CLng(Len(strInputString)) > intStringLength Then
		
		'Get the part in the string to trim it from
		intTrimLentgh = InStr(intStringLength, strInputString, " ", vbTextCompare)
		
		'If intTrimLentgh = 0 then set it to the default passed to the function (Error handling, should never be used)
		If intTrimLentgh = 0 Then intTrimLentgh = intStringLength
		
		'Trim the number of characters down to the required amount, but try not to chop words in half
		strInputString = Mid(strInputString, 1, intTrimLentgh)

		'Make sure the user hasn't entered a long line of text with no break (most words won't be over 30 chars
		If CLng(Len(strInputString)) => intStringLength + 30 Then
			strInputString = Mid(Trim(strInputString), 1, intStringLength)
		End If

		'Place '...' at the end
		 strInputString = Trim(strInputString) & "..."
	End If

	'Return string
	TrimString = strInputString
End Function

 Function HandleError
 	'Save Log here
	Ret = True
 	If Err.Number <> 0 then
		'HandleError Err.Description
		Error.Clear
		Ret = False
	End If
	HandleError = Ret	
End Function

'Format SQL Query funtion
Private Function formatSQLInput(ByVal strInputEntry)

	If strInputEntry=Null then
		formatSQLInput = ""
	Else
	'Remove malisous charcters from links and images
	strInputEntry = Replace(strInputEntry, "<", "&lt;")
	strInputEntry = Replace(strInputEntry, ">", "&gt;")
	strInputEntry = Replace(strInputEntry, """", "", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "=", "&#061;", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "'", "''", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "select", "sel&#101;ct", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "join", "jo&#105;n", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "union", "un&#105;on", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "where", "wh&#101;re", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "insert", "ins&#101;rt", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "delete", "del&#101;te", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "update", "up&#100;ate", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "like", "lik&#101;", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "drop", "dro&#112;", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "create", "cr&#101;ate", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "modify", "mod&#105;fy", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "rename", "ren&#097;me", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "alter", "alt&#101;r", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "cast", "ca&#115;t", 1, -1, 1)
	strInputEntry = Replace(strInputEntry, "form", "", 1, -1, 1)

	'Return
	formatSQLInput = strInputEntry
	End if
End Function

 %>
 
 
