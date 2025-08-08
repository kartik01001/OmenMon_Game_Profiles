' ===============================================
' HP Omen Game Performance Manager (Hidden)
' Starts the manager completely in background
' ===============================================

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' IMPORTANT: Change this path to where your OmenMon Bkg folder is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strBatchFile = strScriptPath & "\GamePerformanceManagerSilent.bat"

' Check if the main script exists
If objFSO.FileExists(strBatchFile) Then
    ' Set working directory and run the batch file hidden
    objShell.CurrentDirectory = strScriptPath
    objShell.Run """" & strBatchFile & """", 0, False
Else
    ' Show error message if file not found
    objShell.Popup "ERROR: GamePerformanceManagerSilent.bat not found!" & vbCrLf & _
                  "Location: " & strScriptPath & vbCrLf & _
                  "Please ensure all files are in the same directory.", _
                  10, "Game Performance Manager", 16
End If

Set objShell = Nothing
Set objFSO = Nothing
