#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_x64=hello.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <StructureConstants.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <WinAPISys.au3>

Dim $keyCodeArray
Dim $keys[0]
Dim $keyCodesTyped

_FileReadToArray( "HELLO-KEYS.TXT", $keyCodeArray, 1, @TAB )
OnAutoItExitRegister( "Cleanup" )

Global $hid_Capture = True

Global $g_hHook, $g_hStub_KbdProc, $g_hStub_MseProc
Local $hMod

$g_hStub_KbdProc = DllCallbackRegister( "_KbdProc", "long", "int;wparam;lparam" )
; $g_hStub_MseProc = DllCallbackRegister( "_MseProc", "long", "int;wparam;lparam" )

$hMod = _WinAPI_GetModuleHandle( 0 )
$kbd_hHook = _WinAPI_SetWindowsHookEx( $WH_KEYBOARD_LL, DllCallbackGetPtr( $g_hStub_KbdProc ), $hMod )
; $mse_hHook = _WinAPI_SetWindowsHookEx( $WH_MOUSE_LL, DllCallbackGetPtr( $g_hStub_MseProc ), $hMod )


 For $i = 1 To 1000
   Sleep( 10 )
Next
   $hid_Capture = False

_ArrayDisplay( $keys )
Exit



; $g_hStub_MseProc = DllCallbackRegister( "_MseProc", "long", "int;wparam;lparam" )

; $hMod = _WinAPI_GetModuleHandle( 0 )
; $mse_hHook = _WinAPI_SetWindowsHookEx( $WH_MOUSE_LL, DllCallbackGetPtr( $g_hStub_MseProc ), $hMod )



Func EvaluateKey( $iKeycode )

   ; #comments-start
    If ( ( $iKeycode > 159 ) And ( $iKeycode < 164 ) ) Then

        Return

    ElseIf ( $iKeycode = 27 ) Then ; esc key

        Exit

    EndIf
	; #comments-end

EndFunc   ;==>EvaluateKey


; ===========================================================
; callback function
; ===========================================================

Func _KbdProc( $nCode, $wParam, $lParam )

	  Local $tKEYHOOKS = DllStructCreate( $tagKBDLLHOOKSTRUCT, $lParam )
	  Local $iFlags = DllStructGetData( $tKEYHOOKS, "flags" )
	  Local $scanCode = DllStructGetData( $tKEYHOOKS, "scanCode" )
	  Local $vkbdCode = DllStructGetData( $tKEYHOOKS, "vkCode" )
	  Local $index = _ArraySearch( $keyCodeArray, $vkbdCode )
	  Local $vkString = $keyCodeArray[ $index ][ 1 ]
	  Local $shiftKeyPressed = ( _WinAPI_GetKeyState ( 10 ) )
	  Local $capsLockOn = ( _WinAPI_GetKeyState ( 20 ) )

	If Not ( $hid_Capture ) Then

		Return ;  _WinAPI_CallNextHookEx( $g_hHook, $nCode, $wParam, $lParam )

	ElseIf ( $nCode < 0 ) Then

        Return ;  _WinAPI_CallNextHookEx( $g_hHook, $nCode, $wParam, $lParam )

    EndIf

    If ( $wParam = $WM_KEYDOWN ) Then

        ; EvaluateKey( DllStructGetData( $tKEYHOOKS, "vkCode" ) )
					ConsoleWrite( $vkString & " DOWN on " & timeStamp() & @CRLF )
			   _ArrayAdd( $keys, $vkbdCode & "-" & "DOWN"  )


    EndIf



        Switch $iFlags

            Case $LLKHF_ALTDOWN
                ConsoleWrite( "$LLKHF_ALTDOWN" & @CRLF )

            Case $LLKHF_EXTENDED
                ConsoleWrite( "$LLKHF_EXTENDED" & @CRLF )

            Case $LLKHF_INJECTED
                ConsoleWrite( "$LLKHF_INJECTED" & @CRLF )

            Case $LLKHF_UP
				ConsoleWrite( $vkString & " UP on " & timeStamp() & @CRLF )
			   _ArrayAdd( $keys, $vkbdCode & "-" & "UP"  )


			Case Else
				; ConsoleWrite( $vkString & " on " & timeStamp() & @CRLF )
			   ; _ArrayAdd( $vkbdCode, $vkbdCode & "-" & $iFlags )





		EndSwitch



    Return _WinAPI_CallNextHookEx( $g_hHook, $nCode, $wParam, $lParam )

EndFunc   ;==>_KeyProcdadf

Func timeStamp()

	Return ( @YEAR & "-" & @MON & "-" & @YEAR & " at " & @HOUR & ":" & @MIN & ":" & @SEC & "." & @MSEC )

EndFunc

Func _MseProc( $nCode, $wParam, $lParam )

    ; Return _WinAPI_CallNextHookEx( $g_hHook, $nCode, $wParam, $lParam )

EndFunc    ;==>_MseProc




Func Cleanup()

    _WinAPI_UnhookWindowsHookEx( $g_hHook )
    DllCallbackFree( $g_hStub_KbdProc )

EndFunc   ;==>Cleanup