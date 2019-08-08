#include <GUIConstantsEx.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>

GUICreate('Test ' & StringReplace(@ScriptName, '.au3', '()'))
GUIRegisterMsg($WM_KEYDOWN, 'WM_KEYDOWN')
GUIRegisterMsg($WM_KEYUP, 'WM_KEYUP')

GUISetState(@SW_SHOW)

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

Func WM_KEYDOWN($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam

    ConsoleWrite(_WinAPI_GetKeyNameText($lParam) & "DOWN" & @CRLF)
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_KEYDOWN

Func WM_KEYUP($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam

    ConsoleWrite(_WinAPI_GetKeyNameText($lParam) & "UP" & @CRLF)
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_KEYUP
