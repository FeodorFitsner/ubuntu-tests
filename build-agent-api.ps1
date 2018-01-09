function WaitAsyncResult($lockPath) {
    while($true) {
        if(Test-Path $lockPath) {
            $result = Get-Content $lockPath
            Remove-Item $lockPath -Force
            if ($result) {
                throw $result
            }
            break
        } else {
            Start-Sleep -m 200
        }
    }
}

function Update-AppveyorBuild() {
    [CmdletBinding()] 
    Param( 
        [Parameter(Mandatory=$false)] 
        [string]$Version
    )
    
    $headers = @{
      "Content-type" = "application/json"
    }
    
    $body = @{
      "version" = $Version
    }
    
    $response = Invoke-WebRequest -Method PUT -Uri $env:APPVEYOR_API_URL/api/build -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
}

function Set-AppveyorBuildVariable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        $Name,

        [Parameter(Position=1, Mandatory=$true)]
        $Value
    )

    $headers = @{
      "Content-type" = "application/json"
    }
    
    $body = @{
      "name" = $Name
      "value" = $Value
    }
    
    $response = Invoke-WebRequest -Method POST -Uri $env:APPVEYOR_API_URL/api/build/variables -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
}

function Push-AppveyorArtifact() {
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        $Path,

        [Parameter(Mandatory=$false)]
        $FileName = $null,

        [Parameter(Mandatory=$false)]
        $DeploymentName = $null,

        [Parameter(Mandatory=$false)]
        $Type = $null,

        [Parameter(Mandatory=$false)]
        $Verbosity = 'Normal'
    )

    #$fullPath = (Resolve-Path $Path).Path
    
    $headers = @{
      "Content-type" = "application/json"
    }
    
    $body = @{
      "cwd" = (pwd).Path
      "path" = $Path
      "fileName" = $FileName
      "name" = $DeploymentName
      "type" = $Type
    }
    
    $response = Invoke-WebRequest -Method POST -Uri $env:APPVEYOR_API_URL/api/artifacts -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
    $respBody = ConvertFrom-Json $response.content
    WaitAsyncResult $respBody.lockPath
}

Update-AppveyorBuild -Version 1.2.$env:APPVEYOR_BUILD_NUMBER-abc
Push-AppveyorArtifact test.js
Set-AppveyorBuildVariable -Name test_variable_1 -Value 'Hi there, variable!'
