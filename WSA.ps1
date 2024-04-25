try {
    $pathToFile = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
    Invoke-WebRequest https://dl.google.com/android/repository/platform-tools-latest-windows.zip -OutFile $pathToFile\ADB.zip
    Invoke-WebRequest https://files.fishbowlinventory.com/2023-12-12/fishbowl-advanced-mobile-6.10.0.apk -OutFile $pathToFile\fishbowl-advanced-mobile-6.10.0.apk

    Expand-Archive -LiteralPath $pathToFile\ADB.zip -DestinationPath $pathToFile\
    
    #open WSA Universal Windows Package and wait for it to open completely before continuing
    $proc = explorer.exe "shell:AppsFolder\$(Get-StartApps "Windows Subsystem for Android" | Select-Object -ExpandProperty AppId)"
    do{
        if ($proc.MainWindowHandle -ne 0)
       {
            break
       }
       $proc.Refresh()
    } while ($true)
    
    #send keyboard input to turn on developer options (this is hacky but it is closed source and no documentation is available on how to do this via cmd)
    function SendKeys {
        param (
            $SENDKEYS,
            $WINDOWTITLE
        )
        $wshell = New-Object -ComObject wscript.shell;
        IF ($WINDOWTITLE) {$wshell.AppActivate($WINDOWTITLE)}
        Start-Sleep 1
        IF ($SENDKEYS) {$wshell.SendKeys($SENDKEYS)}
    }

    SendKeys -SENDKEYS '{DOWN}{DOWN}{ENTER}'
    SendKeys -SENDKEYS '{TAB}{TAB}'
    SendKeys -SENDKEYS ' '
    SendKeys -SENDKEYS '%{f4}'
}
catch {
    <#Do this if a terminating exception happens#>
    "An error occurred."
}
finally {
    "Step 1 Complete"
}
Start-Process WsaClient -Args "/launch wsa://system"
Start-Sleep 30
adb connect 127.0.0.1:58526
Start-Sleep 5
adb install $pathToFile/fishbowl-advanced-mobile-6.10.0.apk
