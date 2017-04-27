function Update-AppveyorBuild() {
    [CmdletBinding()] 
    Param( 
        [Parameter(Mandatory=$false)] 
        [string]$Version
    )
    
    $headers = {
      "Content-type" = "application/json"
    }
    
    $body = {
      "version" = $Version
    }
    
    Invoke-WebRequest -Method PUT -Uri $env:APPVEYOR_API_URL/api/build -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
}

Update-AppveyorBuild -Version 1.2.$env:APPVEYOR_BUILD_NUMBER-abc
