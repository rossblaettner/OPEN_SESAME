#include <MsgBoxConstants.au3>
#include <WinAPIProc.au3>

Example()

Func Example()
	; Run Notepad
	Run("notepad.exe")

	; Wait 10 seconds for the Notepad window to appear.
	Local $hWnd = WinWait("[CLASS:Notepad]", "", 10)

	; Display a list of Notepad processes returned by ProcessList.
	Local $aProcessList = ProcessList("notepad.exe")
	For $i = 1 To $aProcessList[0][0]
		Local $path = _WinAPI_GetProcessFileName( $aProcessList[$i][1] )
		MsgBox( $MB_SYSTEMMODAL, "", $aProcessList[$i][0] & @CRLF & "PID: " & $aProcessList[$i][1])
		MsgBox( $MB_SYSTEMMODAL, "", "Path:"  & $path )

		MsgBox( $MB_SYSTEMMODAL, "", "Version: " & FileGetVersion( $path ) )
		MsgBox( $MB_SYSTEMMODAL, "", "Architecture: " & ( _WinAPI_IsWow64Process( $aProcessList[$i][1] ) ? "32" : "64" ) )


	Next

	; Close the Notepad window using the handle returned by WinWait.
	WinClose($hWnd)
EndFunc   ;==>Example
