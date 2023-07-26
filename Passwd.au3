#include <Security.au3>
#include <Crypt.au3>
#include <WinAPIProc.au3>
#include <IE.au3>
#include "Yubico Yubikey Authentication [Online Version] by Zinthose.au3"
; #include "Monitor Keyboard Mouse.au3"
#include <Array.au3>
#include <StringConstants.au3>

#comments-start

[LoginAssist]
[Application]
[Developer Logging in as..."
[User Name]
[Date & Time Set]
[Expires in 4 days on MM/DD/YY at HH:MM]
[Revoke]

_DateAdd ( "D", 35, $sDate )

WinList
WinGetProcess
_ProcessGetName($iPid)
_WinAPI_GetProcessFileName
_WinAPI_IsWow64Process
( _WinAPI_IsWow64Process( $aProcessList[$i][1] ) ? "32" : "64" )

_IE_VersionInfo

encryption key = domain\user:password:serialos
continue? Exists?

Process @ Front
file

Process @ Front
(Internet Explorer)
URL at front
Certificate-Fingerprint of URL at front
username = exists?
continue = exists?
password = begins with known Yubikey ID?
publicid = yubikey?
password = Yubikey ID is valid?
validity?

Which credentials?

#comments-end



#ce

; Dim $yubikeyClient = 36488
; Dim $yubikeySecret = "45r9+9SoXue+tc4wUEL4T6ctwIE="

#cs

Dim $focus
While 1

Local $hWnd = WinWait("[CLASS:Notepad]", "", 10)
WinWait( "Find" )
Local $process = WinGetProcess( "Find" )
ConsoleWrite( "Process: " & $process & @CRLF )
Local $processFile = _WinAPI_GetProcessFileName( $process )
ConsoleWrite( "File: " & $processFile & @CRLF )
Local $version = FileGetVersion( $processFile )
ConsoleWrite( "Version: " & $version & @CRLF )
Local $architecture = ( _WinAPI_IsWow64Process( $process ) ? "32" : "64" )
ConsoleWrite( "Architecture:" & $architecture & @CRLF )
Local $hash = Hex( ( _Crypt_HashFile( $processFile, $CALG_SHA1 ) ) )
ConsoleWrite( "Hash: " & $hash & @CRLF )

Local $focus = ControlGetFocus( $hWnd )

If( $focus ) Then ConsoleWrite( "Control Text: " & ControlGetText( "Find", "", $focus ) )

ConsoleWrite( $focus )


WEnd

#ce

Dim $appVendor = "BITS"
Dim $appNameFull = "The Sesame Suite"
Dim $appNameNick = "Sesame Suite"

Dim $prefsWild = "*.TXT"
Dim $prefsFile = ""
Dim $prefsPath = ( @AppDataDir & "\" & $appVendor & "\" & $appNameNick )

DirCreate( $prefsPath )

Dim $fileHandle = FileFindFirstFile( $prefsPath & "\" & $prefsWild )

While ( @error == 0 )

   Local $fileName = FileFindNextFile( $fileHandle )
   If ( $fileName ) Then $prefsFile = ( $prefsPath & "\" & $fileName )

WEnd

FileClose( $fileHandle )

; Crypto
Dim $cryptoHash = $CALG_SHA1
Dim $cryptoSymmetric = $CALG_AES_256
Dim $cyptoPassword = "crypt-password"
Dim $cryptoSaltInit = "030356A0"
Dim $sectionName

; Profile Section
Local $domUser = ( _WinAPI_GetProcessUser() )
Local $userName = $domUser[0]
Local $domainos = $domUser[1]
Local $serialos = RegRead( "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography", "MachineGuid" )

$sectionName = ( $domainos & "\" & $userName )

Local $cryptoSalt = hexToASCII( Hex( _Crypt_HashData( ( $cryptoSaltInit & $domainos & $userName & $serialos ), $cryptoHash, True ) ) )
$cryptoSalt = IniRead( $prefsFile, $sectionName, "hashsalt", $cryptoSalt )

Local $publicid = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "publicid", "" ) )


IniWrite( $prefsFile, $sectionName, "hashsalt", $cryptoSalt  )
IniWrite( $prefsFile, $sectionName, "username", cryptSign( $sectionName, $userName ) )
IniWrite( $prefsFile, $sectionName, "domainos", cryptSign( $sectionName, $domainos ) )
IniWrite( $prefsFile, $sectionName, "serialos", cryptSign( $sectionName, $serialos ) )
IniWrite( $prefsFile, $sectionName, "publicid", cryptSign( $sectionName, "vvthlvjvtrrr" ) )

Local $iniProcesses = IniReadSectionNames( $prefsFile )

MsgBox( 0, "$publicid", $publicid )

While ( True )

   Local $processList = ProcessList()
   Local $processCount = $processList[0][0]

   For $i = 1 To $processList[0][0]

	  Local $procFile = $processList[$i][0]
	  Local $procId = $processList[$i][1]

	  Local $procArch = ( _WinAPI_IsWow64Process( $procId ) ? "32" : "64" )
	  Local $procPath = ( _WinAPI_GetProcessFileName( $procId ) )

	  Local $procVersion, $procHashVal

	  $sectionName = ( $procFile & ":" & $procArch )

	  Local $iniIndex = _ArraySearch( $iniProcesses, $sectionName )

	  If ( FileExists( $procPath ) ) Then

		 $procVersion = FileGetVersion( $procPath )
		 $procHashVal = Hex( _Crypt_HashFile( $procPath, $cryptoHash ) )

	  EndIf

	  Local $iniPath = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "file-path", "" ) )
	  Local $iniVersion = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "file-version", "" ) )
	  Local $iniHashVal = IniRead( $prefsFile, $sectionName, "file-hashval", "" )

If ( ( $iniPath & $iniVersion & $iniHashVal ) <> "" ) Then
IniWrite( $prefsFile, $sectionName, "file-path", cryptSign( $sectionName, $iniPath ) )
IniWrite( $prefsFile, $sectionName, "file-version", cryptSign( $sectionName, $iniVersion ) )

EndIf


	  If ( $iniIndex >= 0 ) Then

		 If ( ( $iniPath == "" ) And ( $procPath <> "" ) ) Then IniWrite( $prefsFile, $sectionName, "file-path", cryptSign( $sectionName, $procPath ))
		 If ( ( $iniVersion == "" ) And ( $procVersion <> "" ) ) Then IniWrite( $prefsFile, $sectionName, "file-version", cryptSign( $sectionName, $procVersion ) )
		 If ( ( $iniHashVal == "" ) And ( $procHashVal <> "" ) ) Then IniWrite( $prefsFile, $sectionName, "file-hashval", $procHashVal )

		 Switch ( $procFile )

			Case "iexplore.exe"

			Dim $ieInstance = Null
			Dim $iePasswdVal = ""


			   Local $ieDocTitle = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "doc-title", "" ) )
			   Local $ieWinTitle = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "win-title", "" ) )
			   Local $ieUrlSubSt = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "url-subst", "" ) )

			   ; Only Retrieve Ids, Only Based on Match of Above ^
			   Local $iePasswdId = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "passwd-id", "" ) )
			   Local $iePassword = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "passwd-val", "" ) )
			   Local $ieUserNmId = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "usernm-id", "" ) )
			   Local $ieUsername = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "usernm-val", "" ) )
			   Local $ieSubmitId = cryptRead( $sectionName, IniRead( $prefsFile, $sectionName, "submit-id", "" ) )

				; ConsoleWrite( $iePasswdId & @CRLF )
				; ConsoleWrite( $iePassword & @CRLF )
				; ConsoleWrite( $ieUserNmId & @CRLF )
				; ConsoleWrite( $ieUsername & @CRLF )
				; ConsoleWrite( $ieSubmitId & @CRLF )

;#cs
			   ; IniWrite( $prefsFile, $sectionName, "doc-title", cryptSign( $sectionName, $ieDocTitle ) )
			   ; IniWrite( $prefsFile, $sectionName, "win-title", cryptSign( $sectionName, $ieWinTitle ) )
			   IniWrite( $prefsFile, $sectionName, "url-subst", cryptSign( $sectionName, "https://ihub.ascension.org/login/login.html" ) )
			   IniWrite( $prefsFile, $sectionName, "passwd-id", cryptSign( $sectionName, "pt-login-password-textbox" ) )
			   IniWrite( $prefsFile, $sectionName, "passwd-val", cryptSign( $sectionName, "***example-password***" ) )
			   IniWrite( $prefsFile, $sectionName, "usernm-id", cryptSign( $sectionName, "pt-login-username-textbox" ) )
			   IniWrite( $prefsFile, $sectionName, "usernm-val", cryptSign( $sectionName, "rblaettn" ) )
			   IniWrite( $prefsFile, $sectionName, "submit-id", cryptSign( $sectionName, "btnSubmit" ) )

;#ce
; TO DO: Match Multiple (Matching) Instances (by Instance ID#), Iterate until all instances are exhausted

; Turn off console warnings about attach issues
_IEErrorNotify( False )

			   $ieInstance = ( _IEAttach( $ieDocTitle, "title" ) )

			   If ( @error == 0 ) Then

				 $iePasswdVal = ieWatchLogin( $ieInstance, $iePasswdId )

				 If ( StringLeft( $iePasswdVal, StringLen( $publicid ) ) == $publicid ) Then

					; MsgBox( 0, "Public ID Detected", $publicid )

				 EndIf

			   EndIf

			   $ieInstance = ( _IEAttach( $ieWinTitle, "windowtitle" ) )

			   If ( @error == 0 ) Then

				 $iePasswdVal = ieWatchLogin( $ieInstance, $iePasswdId )

				 If ( StringLeft( $iePasswdVal, StringLen( $publicid ) ) == $publicid ) Then

					; MsgBox( 0, "Public ID Detected", $publicid )

				 EndIf

			   EndIf

			   $ieInstance = ( _IEAttach( $ieUrlSubSt, "url" ) )

			   If ( @error == 0 ) Then

				 $iePasswdVal = ieWatchLogin( $ieInstance, $iePasswdId ) ; Problem??

				 If ( StringLeft( $iePasswdVal, StringLen( $publicid ) ) == $publicid ) Then

					; MsgBox( 0, "Public ID Detected", $publicid )

						If( StringLen( $iePasswdVal ) == 44 ) Then

							  Local $yubikeyValidation = ( _Yubikey_Validate( $iePasswdVal ) )
						   If ( $yubikeyValidation == $YUBIKEY_OK ) Then

							  ieLoginAs( $ieInstance, $iePasswdId, $iePassword, $ieUserNmId, $ieUsername, $ieSubmitId )

						   Else

							  	ieLoginAs( $ieInstance, $iePasswdId, "", $ieUserNmId, "", $ieSubmitId  )
								; MsgBox( 0, "YubiKey Authentication", $yubikeyValidation )

						   EndIf

						EndIf

					 EndIf

			   EndIf


		 EndSwitch

	  EndIf

   Sleep ( 10 )

Next

; Sleep ( 100 )

WEnd

Exit

Local $winHandle = 0

While Not $winHandle

   $winHandle = WinActive( "Perceptive Content" )
   Sleep( 500 )

WEnd

ConsoleWrite( "GOT APP!" & @CRLF )


Local $controlFocus = ""

While 1

   $controlFocus = ControlGetFocus( $winHandle )
   If ( $controlFocus ) == "Edit2" Then ExitLoop

   Sleep( 100 )

WEnd

ConsoleWrite( "FOCUSED" & @CRLF )





While ( $controlFocus == "Edit2" )

   $controlFocus = ControlGetFocus( $winHandle )

WEnd


ConsoleWrite( "UN-FOCUSED" & @CRLF )
$hid_Capture = False


$ieTab = _IEAttach( "Gmail", "windowtitle" )
; _IEFormGetCollection ( ByRef $oObject [, $iIndex = -1] )
; Local $ieTab =  _IEAttach ( $sString [, $sMode = "title" [, $iInstance = 1]] )
; Local $ieForms = _IEFormGetCollection( $oIE, 0 )
; Local $ieForm = _IEFormElementGetCollection( $oForm, 4 )
; _IEFormElementSetValue($oQuery, "AutoIt IE.au3")

Dim $value

If ( @error == 0 ) Then

	$ieObj = _IEGetObjById( $ieTab, "identifierId" )
	_IEFormElementSetValue( $ieObj, "rblaettner" )
	$value = _IEFormElementGetValue( $ieObj )
	; MsgBox( 0, "Attached", "Data: " & $data & @CRLF & "Hash: " & $hash & @CRLF & "Value: " & $value )

EndIf





Func hexToASCII( $hex )

	Return $hex ; override, compatibility

	Local $ascii = ""

	For $i = 1 To StringLen( $hex ) Step 2

		Local $char = Chr( Dec( StringMid( $hex, $i, 2 ) ) )
		$ascii &= $char

	Next

	Return $ascii

EndFunc

Func ASCIItoHex( $ascii )

	Return $ascii ; override, compatibility
	Local $hex = ""

	For $i = 1 To StringLen ( $ascii ) Step 1

		Local $hexVal = Hex( Asc( StringMid( $ascii, $i, 1 ) ), 2 )
		$hex &= $hexVal

	Next

	Return $hex

EndFunc

Func hashCapped( $salt, $string )

	Return Hex( _Crypt_HashData( ( ( $cryptoSalt & $salt ) & StringUpper( $string ) ), $cryptoHash ) )

EndFunc

Func cryptSign( $salt, $string )

	Local $data = Hex( _Crypt_EncryptData( $string, $cyptoPassword, $cryptoSymmetric, True ) )
	$data = hexToASCII( $data )
	Return ( $data & ":" & ( cryptSignOnly( $salt, $data ) ) )

EndFunc

Func cryptSignOnly( $salt, $data )

	Return hexToASCII( Hex( _Crypt_HashData( ( $cryptoSalt & $salt ) & $data, $cryptoHash ) ) )

EndFunc

Func cryptRead( $salt, $string )

	Local $cipherTextSignature = StringSplit( $string, ":", $STR_ENTIRESPLIT )

	If Not ( $cipherTextSignature[0] == 2 ) Then Return ""

	Local $cipherText = $cipherTextSignature[1]
	Local $signature = $cipherTextSignature[2]

	If Not ( cryptSignOnly( $salt, $cipherText ) == $signature ) Then Return ""

	$cipherText = asciiToHex( $cipherText )

	Local $data = BinaryToString( _Crypt_DecryptData( ( "0x" & $cipherText ), $cyptoPassword, $cryptoSymmetric, True ) )

	Return $data

EndFunc

Func ieLoginAs( $ieInstance, $passwordId, $passwordVal, $usernameId, $usernameVal, $submitId )

   ; Reload the page, fresh (and verify certificate chain AND/OR fingerprint for HTTPS) -- and wait until fully loaded before ...
   ; ^ This (helps to) prevent(s) JavaScript injections... by reducing timeframe -- unless there is an "override parameter" in INI (for web page compatibilty)

   Local $passwordObj = ( _IEGetObjById( $ieInstance, $passwordId ) )

   If ( @error <> 0 ) Then Return

   Local $usernameObj = ( _IEGetObjById( $ieInstance, $usernameId ) )

   If ( @error <> 0 ) Then Return

   Local $submitObj = ( _IEGetObjById( $ieInstance, $submitId ) )

   If ( @error <> 0 ) Then Return

   ; Lock Keyboard & Mouse

   _IEFormElementSetValue( $passwordObj, $passwordVal )
   _IEFormElementSetValue( $usernameObj, $usernameVal )

   ; Wait 500 ms and unlock keyboard and mouse ... or respond to other indicator of success/failure ?

   _IEAction( $submitObj, "click" )

EndFunc

Func ieWatchLogin( ByRef $ieInstance, $passwordId )

   Local $passwordObj = ( _IEGetObjById( $ieInstance, $passwordId ) )

   If ( @error <> 0 ) Then Return ""


   Local $passwordVal = ( _IEFormElementGetValue( $passwordObj ) )

   If ( @error <> 0 ) Then Return ""

   Return $passwordVal

EndFunc

Func iniReadSectionKeyValue( $file, $section, $key, $value )
EndFunc
