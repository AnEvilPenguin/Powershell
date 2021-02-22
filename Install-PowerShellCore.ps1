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
        Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList $Arguments -Wait
        Remove-Item -Path "$env:TEMP\$MSI"
    }
    Else {
        Write-Error -Message "Something went wrong downloading the latest pwsh msi from https://www.github.com$Link" -RecommendedAction 'Install it manually' -Category ObjectNotFound -ErrorAction Stop
    }
    #Sanity Check     
}
#Checks if pwsh is installed and installs the latest version if not
