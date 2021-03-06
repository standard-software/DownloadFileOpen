Option Explicit

'--------------------------------------------------
'■Include st.vbs
'--------------------------------------------------
Sub Include(ByVal FileName)
    Dim fso: Set fso = WScript.CreateObject("Scripting.FileSystemObject") 
    Dim Stream: Set Stream = fso.OpenTextFile( _
        fso.GetParentFolderName(WScript.ScriptFullName) _
        + "\" + FileName, 1)
    Call ExecuteGlobal(Stream.ReadAll())
    Call Stream.Close
End Sub
'--------------------------------------------------
Call Include(".\Lib\st.vbs")
'--------------------------------------------------

'------------------------------
'◇メイン処理
'------------------------------
Call Main

Sub Main
Do
    Dim Args: Set Args = WScript.Arguments

    If Args.Count = 0 Then
        MsgBox "起動引数が指定されていません。" + vbCrLf + _
            "処理を停止します" 
        Exit Do
    End If

    Dim DownloadPath
    DownloadPath = PathCombine(Array( _
        EnvironmentalVariables("PROGRAMDATA"), _
        "StandardSoftware\DownloadFileOpen\Download"))
    Call ForceCreateFolder(DownloadPath)

    Dim CopyFileFlag
    CopyFileFlag = False

    Dim I
    For I = 0 to Args.Count - 1
        Dim FilePath: FilePath = Args(I)

        If UCase(PeriodExtName(FilePath)) = ".LNK" then
            'ショートカットファイルの場合はオリジナルファイルを割り当てる
            FilePath = ShortcutFileLinkPath(FilePath)
        End If

        If fso.FileExists(FilePath) Then

            '同名ファイルの削除処理
            Dim FileArray
            FileArray = Split( _
                FilePathListTopFolder(DownloadPath), vbCrLf)
            Dim J
            For J = 0 to ArrayCount(FileArray) - 1
                If IsFirstStr(fso.GetFileName(FileArray(J)), _
                    fso.GetBaseName(FilePath)) Then
                    call fso.DeleteFile(FileArray(J), True)
                End IF
            Next

            CopyFileFlag = True
            Dim CopyToPath
            CopyToPath = IncludeLastPathDelim(DownloadPath) + _ 
                fso.GetBaseName(FilePath) + "_" + _
                FormatYYYYMMDDHHMMSS(Now()) + _
                "." + fso.GetExtensionName(FilePath)
            Call fso.CopyFile(FilePath, CopyToPath)

            Do While not fso.FileExists(CopyToPath)
            Loop

            '読み取り専用属性にする
            Dim File: Set File = fso.GetFile(CopyToPath)
            File.Attributes = File.Attributes or 1

            Call ShellFileOpen(CopyToPath, vbNormalFocus)
        End If
    Next

    If CopyFileFlag = False Then
        MsgBox "起動引数にファイルが指定されていません。" + vbCrLf + _
            "処理を停止します" 
        Exit Do
    End If

    Loop While False
End Sub
