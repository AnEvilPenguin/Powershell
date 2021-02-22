If (-not (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\pwsh.exe')) {
    $Response = Invoke-WebRequest -uri 'https://aka.ms/powershell-release?tag=stable' -UseBasicParsing

    If ([System.IntPtr]::Size -eq '8') {
        $Link = ($Response.Links | Where-Object {$_ -like "*64.msi*"}).href
    }
    Else {
        $Link = ($Response.Links | Where-Object {$_ -like "*86.msi*"}).href
    }

    $MSI = $($Link.Split('/')[-1])
    [system.net.Webclient]::new().DownloadFile("https://www.github.com$Link","$env:TEMP\$MSI")

    If (Test-Path -Path "$env:TEMP\$MSI") {
        $Arguments = @(
            '/i'
            "$env:TEMP\$MSI"
            '/qn'
            '/norestart'
        )
        
        while (((New-Object -ComObject "Microsoft.Update.Installer").isbusy) -or ((Get-Process msiexec -ErrorAction SilentlyContinue).count -gt 1)) {
            Start-Sleep -Seconds 10
        }
        #Check to make sure that updates and msiexec aren't currently busy
        #Sleep until they are not
        
        Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList $Arguments -Wait
        #Actually install

        Remove-Item -Path "$env:TEMP\$MSI"
        #Clean up after ourselves
    }
    Else {
        Write-Error -Message "Something went wrong downloading the latest pwsh msi from https://www.github.com$Link" -RecommendedAction 'Install it manually' -Category ObjectNotFound -ErrorAction Stop
    }
    #Sanity Check     
}
#Checks if pwsh is installed and installs the latest version if not
