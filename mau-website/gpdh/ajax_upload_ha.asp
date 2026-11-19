<%
Response.Buffer = True
Response.Expires = -1
Response.Clear

Sub BuildUploadRequest(RequestBin)
  PosBeg = 1
  PosEnd = InstrB(PosBeg,RequestBin,getByteString(chr(13)))
  if PosEnd = 0 then Exit Sub
  boundary = MidB(RequestBin,PosBeg,PosEnd-PosBeg)
  boundaryPos = InstrB(1,RequestBin,boundary)
  Do until (boundaryPos=InstrB(RequestBin,boundary & getByteString("--")))
    Dim UploadControl
    Set UploadControl = CreateObject("Scripting.Dictionary")
    Pos = InstrB(BoundaryPos,RequestBin,getByteString("Content-Disposition"))
    Pos = InstrB(Pos,RequestBin,getByteString("name="))
    PosBeg = Pos+6
    PosEnd = InstrB(PosBeg,RequestBin,getByteString(chr(34)))
    Name = getString(MidB(RequestBin,PosBeg,PosEnd-PosBeg))
    PosFile = InstrB(BoundaryPos,RequestBin,getByteString("filename="))
    PosBound = InstrB(PosEnd,RequestBin,boundary)
    If  PosFile<>0 AND (PosFile<PosBound) Then
      PosBeg = PosFile + 10
      PosEnd =  InstrB(PosBeg,RequestBin,getByteString(chr(34)))
      FileName = getString(MidB(RequestBin,PosBeg,PosEnd-PosBeg))
      FileName = Mid(FileName,InStrRev(FileName,"\")+1)
      UploadControl.Add "FileName", FileName
      Pos = InstrB(PosEnd,RequestBin,getByteString("Content-Type:"))
      PosBeg = Pos+14
      PosEnd = InstrB(PosBeg,RequestBin,getByteString(chr(13)))
      ContentType = getString(MidB(RequestBin,PosBeg,PosEnd-PosBeg))
      UploadControl.Add "ContentType",ContentType
      PosBeg = PosEnd+4
      PosEnd = InstrB(PosBeg,RequestBin,boundary)-2
      Value = FileName
      ValueBeg = PosBeg-1
      ValueLen = PosEnd-Posbeg
    Else
      Pos = InstrB(Pos,RequestBin,getByteString(chr(13)))
      PosBeg = Pos+4
      PosEnd = InstrB(PosBeg,RequestBin,boundary)-2
      Value = getString(MidB(RequestBin,PosBeg,PosEnd-PosBeg))
      ValueBeg = 0
      ValueLen = 0
    End If
    UploadControl.Add "Value" , Value 
    UploadControl.Add "ValueBeg" , ValueBeg
    UploadControl.Add "ValueLen" , ValueLen 
    UploadRequest.Add name, UploadControl 
    BoundaryPos=InstrB(BoundaryPos+LenB(boundary),RequestBin,boundary)
  Loop
End Sub

Function getByteString(StringStr)
  For i = 1 to Len(StringStr)
    char = Mid(StringStr,i,1)
    getByteString = getByteString & chrB(AscB(char))
  Next
End Function

Function getString(StringBin)
  getString =""
  For intCount = 1 to LenB(StringBin)
    getString = getString & chr(AscB(MidB(StringBin,intCount,1))) 
  Next
End Function

' --- XỬ LÝ NHẬN VÀ LƯU FILE AN TOÀN ---
If Request.TotalBytes > 0 Then
  RequestBin = Request.BinaryRead(Request.TotalBytes)
  Dim UploadRequest
  Set UploadRequest = CreateObject("Scripting.Dictionary")  
  BuildUploadRequest RequestBin
  
  AF_keys = UploadRequest.Keys
  for AF_i = 0 to UploadRequest.Count - 1
    AF_curKey = AF_keys(AF_i)
    if UploadRequest.Item(AF_curKey).Item("FileName") <> "" then
      AF_valueBeg = UploadRequest.Item(AF_curKey).Item("ValueBeg")
      AF_valueLen = UploadRequest.Item(AF_curKey).Item("ValueLen")
      
      if AF_valueLen > 0 then
        
        ' 1. BÓC TÁCH VÀ KIỂM TRA ĐUÔI FILE (CHỐNG MÃ ĐỘC)
        Dim originalFileName, fileExtension, allowedExtensions
        originalFileName = UploadRequest.Item(AF_curKey).Item("FileName")
        fileExtension = LCase(Mid(originalFileName, InStrRev(originalFileName, ".") + 1))
        
        ' Thiết lập danh sách đuôi file được phép tải lên
        allowedExtensions = "|jpg|jpeg|png|gif|webp|"
        If InStr(allowedExtensions, "|" & fileExtension & "|") = 0 Then
            Response.Write "Lỗi: Định dạng file không hợp lệ!"
            Response.End
        End If

        Dim AF_strm1, AF_strm2
        Set AF_strm1 = Server.CreateObject("ADODB.Stream")
        Set AF_strm2 = Server.CreateObject("ADODB.Stream")
        
        AF_strm1.Open
        AF_strm1.Type = 1 'Binary
        AF_strm2.Open
        AF_strm2.Type = 1 'Binary
          
        AF_strm1.Write RequestBin
        AF_strm1.Position = AF_ValueBeg
        AF_strm1.CopyTo AF_strm2, AF_ValueLen
      
        ' 2. XÁC ĐỊNH ĐƯỜNG DẪN LƯU FILE
        Dim AF_curPath
        AF_curPath ="../Images/Hinhanh/" 
        AF_curPath = Trim(Mid(AF_curPath,1,InStrRev(AF_curPath,"/")) & "")
        if Mid(AF_curPath,Len(AF_curPath),1) <> "/" then
          AF_curPath = AF_curPath & "/"
        end if  
        
        ' 3. ĐỔI TÊN FILE THEO ĐỊNH DẠNG: YYYYMMDDHHMMSS_tenfile.jpg
        Dim strYear, strMonth, strDay, strHour, strMinute, strSecond
        strYear = Year(Now)
        strMonth = Right("0" & Month(Now), 2)
        strDay = Right("0" & Day(Now), 2)
        strHour = Right("0" & Hour(Now), 2)
        strMinute = Right("0" & Minute(Now), 2)
        strSecond = Right("0" & Second(Now), 2)
        
        Dim finalFileName
        finalFileName = strYear & strMonth & strDay & strHour & strMinute & strSecond & "_" & originalFileName
        
        ' 4. THỰC THI LƯU FILE LÊN SERVER
        AF_strm2.SaveToFile Trim(Server.mappath(AF_curPath)) & "\" & finalFileName, 2
        
        ' Giải phóng bộ nhớ
        AF_strm1.Close
        Set AF_strm1 = Nothing
        AF_strm2.Close
        Set AF_strm2 = Nothing
        
        ' 5. TRẢ VỀ TÊN FILE CHO AJAX KẾT THÚC QUÁ TRÌNH
        Response.Write finalFileName
        Response.End
      end if
    end if
  next
End If
%>