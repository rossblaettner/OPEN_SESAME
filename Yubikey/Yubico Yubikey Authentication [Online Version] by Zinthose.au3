#cs - About
    This is a demo of a simple Yubikey authentication system.
    This requires an active internet connection to use the Yubico authentication servers.
    Further information on this technology can be aquired from [http://yubico.com]

    Coded by Zinthose [AutoIt Forumns - http://www.autoitscript.com/forum]
#ce

#Region ; - Yubico Yubikey Authentication [Online Version]
    #include <INet.au3>

    Global Const $YUBIKEY_OK                    = "OK";                     <-- The OTP is valid.
    Global Const $YUBIKEY_BAD_OTP               = "BAD_OTP";                <-- The OTP is invalid format.
    Global Const $YUBIKEY_REPLAYED_OTP          = "REPLAYED_OTP";           <-- The OTP has already been seen by the service.
    Global Const $YUBIKEY_BAD_SIGNATURE         = "BAD_SIGNATURE";          <-- The HMAC signature verification failed. (Not yet implemented)
    Global Const $YUBIKEY_MISSING_PARAMETER     = "MISSING_PARAMETER";      <-- The request lacks parameter given by key info.
    Global Const $YUBIKEY_NO_SUCH_CLIENT        = "NO_SUCH_CLIENT";         <-- The request id does not exist.
    Global Const $YUBIKEY_OPERATION_NOT_ALLOWED = "OPERATION_NOT_ALLOWED";  <-- The request id is not allowed to verify OTPs.
    Global Const $YUBIKEY_BACKEND_ERROR         = "BACKEND_ERROR";          <-- Unexpected error in our server. Please contact us if you see this error. (support@yubico.com)
    Global Const $YUBIKEY_PARSE_FAIL            = "PARSE_FAIL";             <-- Corupted Reply: Check Proxy, Network, ect.  This can also be cause if the Yubico net API changed. (http://yubico.com/developers/api)

    ;## Get the Key's ID
        Func _Yubikey_GetID($OTP)
            Local $ID, $Key, $Len

            ;## Validate Parameters
                If Not IsString($OTP)   Then Return SetError(1, 0, $YUBIKEY_BAD_OTP)
                $Len = StringLen($OTP)
                If $Len < 44            Then Return SetError(2, 0, $YUBIKEY_BAD_OTP)

            ;## Extract $ID
                $ID     = StringMid($OTP, $Len - 43, 12)

                Return $ID
        EndFunc

    ;## Validate the Yubikey One time password
        Func _Yubikey_Validate($OTP, $ID = Default)
            Local $URL, $Result
            Local Const $Pattern = "(?i)(?m)^status=(.+)"

            ;## Validate Parameters
                If $ID = Default        Then $ID = 87
                If Not IsNumber($ID)    Then Return SetError(1, 0, $YUBIKEY_NO_SUCH_CLIENT)
                If Not IsString($OTP)   Then Return SetError(2, 0, $YUBIKEY_BAD_OTP)
                If StringLen($OTP) <> 44 Then Return SetError(3, 0, $YUBIKEY_BAD_OTP)

            ;## Connect to the Yubico Servers to Validate
                $URL = 'https://api.yubico.com/wsapi/verify?otp=' & _INetExplorerCapable($OTP) & '&id=' & _INetExplorerCapable($ID)
                $Result = _INetGetSource($URL)

            ;## Return Results
                If StringRegExp($Result, $Pattern) = 0 Then Return SetError(4, 0, $YUBIKEY_PARSE_FAIL)
                $Result = StringRegExp($Result, $Pattern, 1)

                Return $Result[0]
        EndFunc

#EndRegion

#comments-start
#Region ; - Example
    Dim $OneTimePassword, $KeyID, $AuthenticationResult

    ;## Get the Yubikey Value
        $OneTimePassword = InputBox("Yubikey Authenticator", "Enter Yubikey OTP:", "", "*")

    ;## Get the Key's Unique ID (This can be tied to a user's account)
        $KeyID = _Yubikey_GetID($OneTimePassword)

    ;## Validate / Authenticate the The OneTimePassword
        $AuthenticationResult = _Yubikey_Validate($OneTimePassword)

    ;## Display Results

#EndRegion
#comments-end
