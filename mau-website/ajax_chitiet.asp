<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="connection.asp"-->
<%
    Function ParsePersonID(ByVal rawValue)
        Dim textValue, i, currentChar, parsedValue
        ParsePersonID = 0
        If IsNull(rawValue) Or IsEmpty(rawValue) Then Exit Function

        textValue = Trim(CStr(rawValue))
        If textValue = "" Then Exit Function
        For i = 1 To Len(textValue)
            currentChar = Mid(textValue, i, 1)
            If currentChar < "0" Or currentChar > "9" Then Exit Function
        Next

        On Error Resume Next
        parsedValue = CLng(textValue)
        If Err.Number = 0 Then
            If parsedValue > 0 Then ParsePersonID = parsedValue
        End If
        Err.Clear
        On Error GoTo 0
    End Function

    Function PersonText(ByVal rawValue)
        If IsNull(rawValue) Or IsEmpty(rawValue) Then
            PersonText = ""
        Else
            PersonText = Trim(CStr(rawValue))
        End If
    End Function

    Dim requestedPersonId : requestedPersonId = ParsePersonID(Request.QueryString("id"))
    If requestedPersonId > 0 Then
        openconn()

        Dim rs
        Set rs = conn.Execute("SELECT idgiapha, hoten, tentu, namsinh, nammat, huongtho, noiantang, hinhanh FROM tblgiapha WHERE idgiapha=" & requestedPersonId)
        If Not rs.EOF Then
            Dim personId, fullName, alternateName, birthYear, deathYear
            Dim lifespan, burialPlace, nodeImg

            personId = CLng(rs("idgiapha"))
            fullName = PersonText(rs("hoten"))
            alternateName = PersonText(rs("tentu"))
            birthYear = PersonText(rs("namsinh"))
            deathYear = PersonText(rs("nammat"))
            lifespan = PersonText(rs("huongtho"))
            burialPlace = PersonText(rs("noiantang"))
            nodeImg = PersonText(rs("hinhanh"))
%>
            <style>
                .person-detail-card {
                    box-sizing: border-box;
                    width: 100%;
                    min-width: 320px;
                    max-width: 560px;
                    padding: 28px;
                    color: #334155;
                    background: #fff;
                    font-family: 'Nunito', Arial, sans-serif;
                }
                .person-detail-header {
                    display: flex;
                    gap: 20px;
                    align-items: center;
                    padding-bottom: 20px;
                    margin-bottom: 18px;
                    border-bottom: 2px solid #d1a659;
                }
                .person-detail-photo,
                .person-detail-avatar-placeholder {
                    box-sizing: border-box;
                    width: 96px;
                    height: 96px;
                    flex: 0 0 96px;
                    border: 3px solid #e2e8f0;
                    border-radius: 50%;
                }
                .person-detail-photo { display: block; object-fit: cover; }
                .person-detail-avatar-placeholder {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #94a3b8;
                    background: #f1f5f9;
                    font-size: 48px;
                }
                .person-detail-name-label {
                    display: block;
                    margin-bottom: 5px;
                    color: #64748b;
                    font-size: 13px;
                    font-weight: 700;
                    letter-spacing: .03em;
                    text-transform: uppercase;
                }
                .person-detail-name {
                    margin: 0;
                    color: #2b3a22;
                    font-family: 'Philosopher', Georgia, serif;
                    font-size: 25px;
                    line-height: 1.25;
                    overflow-wrap: anywhere;
                }
                .person-detail-list { margin: 0; }
                .person-detail-row {
                    display: grid;
                    grid-template-columns: minmax(105px, 36%) minmax(0, 1fr);
                    gap: 14px;
                    padding: 10px 0;
                    border-bottom: 1px solid #eef2f7;
                }
                .person-detail-row dt,
                .person-detail-row dd { margin: 0; }
                .person-detail-row dt { color: #475569; font-weight: 700; }
                .person-detail-row dd { color: #1e293b; overflow-wrap: anywhere; }
                .person-detail-actions { margin-top: 24px; text-align: center; }
                .person-detail-link {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    min-height: 44px;
                    padding: 0 24px;
                    border-radius: 6px;
                    color: #fff;
                    background: #557b43;
                    font-size: 14px;
                    font-weight: 800;
                    letter-spacing: .03em;
                    text-decoration: none;
                    transition: background-color .2s ease;
                }
                .person-detail-link:hover,
                .person-detail-link:focus { color: #fff; background: #3f6031; }

                @media (max-width: 768px) {
                    .person-detail-card { min-width: 0; min-height: 100%; padding: 58px 20px 24px; }
                    .person-detail-header { align-items: flex-start; gap: 15px; }
                    .person-detail-photo,
                    .person-detail-avatar-placeholder { width: 82px; height: 82px; flex-basis: 82px; }
                    .person-detail-avatar-placeholder { font-size: 40px; }
                    .person-detail-name { font-size: 22px; }
                    .person-detail-row { grid-template-columns: 105px minmax(0, 1fr); gap: 10px; }
                    .person-detail-link { box-sizing: border-box; width: 100%; }
                }
            </style>

            <div class="person-detail-card">
                <div class="person-detail-header">
                    <% If nodeImg <> "" Then %>
                        <img class="person-detail-photo" src="<%=Server.HTMLEncode(nodeImg)%>" alt="Ảnh <%=Server.HTMLEncode(fullName)%>">
                    <% Else %>
                        <div class="person-detail-avatar-placeholder" aria-label="Chưa có ảnh đại diện">
                            <i class="fa fa-user" aria-hidden="true"></i>
                        </div>
                    <% End If %>
                    <div>
                        <span class="person-detail-name-label">Họ và tên:</span>
                        <h2 class="person-detail-name"><%=Server.HTMLEncode(fullName)%></h2>
                    </div>
                </div>

                <dl class="person-detail-list">
                    <% If alternateName <> "" Then %>
                        <div class="person-detail-row"><dt>Tên tự:</dt><dd><%=Server.HTMLEncode(alternateName)%></dd></div>
                    <% End If %>
                    <% If birthYear <> "" Then %>
                        <div class="person-detail-row"><dt>Năm sinh:</dt><dd><%=Server.HTMLEncode(birthYear)%></dd></div>
                    <% End If %>
                    <% If deathYear <> "" Then %>
                        <div class="person-detail-row"><dt>Năm mất:</dt><dd><%=Server.HTMLEncode(deathYear)%></dd></div>
                    <% End If %>
                    <% If lifespan <> "" Then %>
                        <div class="person-detail-row"><dt>Hưởng thọ:</dt><dd><%=Server.HTMLEncode(lifespan)%> tuổi</dd></div>
                    <% End If %>
                    <% If burialPlace <> "" Then %>
                        <div class="person-detail-row"><dt>An táng tại:</dt><dd><%=Server.HTMLEncode(burialPlace)%></dd></div>
                    <% End If %>
                </dl>

                <div class="person-detail-actions">
                    <a class="person-detail-link" href="/giapha/<%=personId%>">XEM CHI TIẾT</a>
                </div>
            </div>
<%
        End If
        rs.Close : Set rs = Nothing
        destroyconn()
    End If
%>
