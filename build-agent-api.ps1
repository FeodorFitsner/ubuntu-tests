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

function Add-AppveyorMessage
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        $Message,

        [Parameter(Mandatory=$false)]
        $Category = $null,

        [Parameter(Mandatory=$false)]
        $Details = $null
    )

    $body = @{
      "message" = $Message
      "category" = $Category
      "details" = $Details
    }
    
    $response = Invoke-WebRequest -Method POST -Uri $env:APPVEYOR_API_URL/api/build/messages -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
}

function Add-AppveyorCompilationMessage
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        $Message,

        [Parameter(Mandatory=$false)]
        $Category = $null,

        [Parameter(Mandatory=$false)]
        $Details = $null,

        [Parameter(Mandatory=$false)]
        $FileName = $null,

        [Parameter(Mandatory=$false)]
        [int]$Line = $null,

        [Parameter(Mandatory=$false)]
        [int]$Column = $null,

        [Parameter(Mandatory=$false)]
        $ProjectName = $null,

        [Parameter(Mandatory=$false)]
        $ProjectFileName = $null
    )

    $body = @{
      "message" = $Message
      "category" = $Category
      "details" = $Details
      "fileName" = $FileName
      "line" = $Line
      "column" = $Column
      "projectName" = $ProjectName
      "projectFileName" = $ProjectFileName
    }
    
    $response = Invoke-WebRequest -Method POST -Uri $env:APPVEYOR_API_URL/api/build/compilationmessages -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
}

function Add-AppveyorTest
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        $Name,

        [Parameter(Mandatory=$false)]
        $Framework = $null,

        [Parameter(Mandatory=$false)]
        $FileName = $null,

        [Parameter(Mandatory=$false)]
        $Outcome = $null,

        [Parameter(Mandatory=$false)]
        [long]$Duration = $null,

        [Parameter(Mandatory=$false)]
        $ErrorMessage = $null,

        [Parameter(Mandatory=$false)]
        $ErrorStackTrace = $null,

        [Parameter(Mandatory=$false)]
        $StdOut = $null,

        [Parameter(Mandatory=$false)]
        $StdErr = $null
    )

    $body = @{
      "name" = $Name
      "framework" = $Framework
      "fileName" = $FileName
      "outcome" = $Outcome
      "duration" = $Duration
      "errorMessage" = $ErrorMessage
      "errorStackTrace" = $ErrorStackTrace
      "stdOut" = $StdOut
      "stdErr" = $StdErr      
    }
    
    $response = Invoke-WebRequest -Method POST -Uri $env:APPVEYOR_API_URL/api/tests -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
}


function Update-AppveyorTest
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        $Name,

        [Parameter(Mandatory=$false)]
        $Framework = $null,

        [Parameter(Mandatory=$false)]
        $FileName = $null,

        [Parameter(Mandatory=$false)]
        $Outcome = $null,

        [Parameter(Mandatory=$false)]
        [long]$Duration = $null,

        [Parameter(Mandatory=$false)]
        $ErrorMessage = $null,

        [Parameter(Mandatory=$false)]
        $ErrorStackTrace = $null,

        [Parameter(Mandatory=$false)]
        $StdOut = $null,

        [Parameter(Mandatory=$false)]
        $StdErr = $null
    )

    $body = @{
      "name" = $Name
      "framework" = $Framework
      "fileName" = $FileName
      "outcome" = $Outcome
      "duration" = $Duration
      "errorMessage" = $ErrorMessage
      "errorStackTrace" = $ErrorStackTrace
      "stdOut" = $StdOut
      "stdErr" = $StdErr      
    }
    
    $response = Invoke-WebRequest -Method PUT -Uri $env:APPVEYOR_API_URL/api/tests -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
}

function Add-AppveyorTestsTest
{
    $body = @(
        @{
          "name" = 'Test Batch A'
          "framework" = 'NUnit'
          "fileName" = 'FileName1.dll'
          "outcome" = 'Running'     
        },
        @{
          "name" = 'Test Batch B'
          "framework" = 'NUnit'
          "fileName" = 'FileName1.dll'
          "outcome" = 'Running'
        }
    )
    
    $response = Invoke-WebRequest -Method POST -Uri $env:APPVEYOR_API_URL/api/tests/batch -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
}

function Update-AppveyorTestsTest
{
    $body = @(
        @{
          "name" = 'Test Batch A'
          "framework" = 'NUnit'
          "fileName" = 'FileName1.dll'
          "outcome" = 'Passed'
          "duration" = 12000
          "errorMessage" = 'Error message'
          "errorStackTrace" = 'Stack Trace!'
          "stdOut" = 'StdOut!'
          "stdErr" = 'StdErr!'     
        },
        @{
          "name" = 'Test Batch B'
          "framework" = 'NUnit'
          "fileName" = 'FileName1.dll'
          "outcome" = 'Failed'
          "duration" = 120
        }
    )
    
    $response = Invoke-WebRequest -Method PUT -Uri $env:APPVEYOR_API_URL/api/tests/batch -Headers $headers -Body (ConvertTo-Json $body -Depth 6)
}

Write-Host "Testing Update-AppveyorBuild..."
Update-AppveyorBuild -Version 1.2.$env:APPVEYOR_BUILD_NUMBER-abc

Write-Host "Testing Push-AppveyorArtifact..."
Push-AppveyorArtifact test.js

Write-Host "Testing Set-AppveyorBuildVariable..."
Set-AppveyorBuildVariable -Name test_variable_1 -Value 'Hi there, variable!'

Write-Host "Testing Add-AppveyorMessage..."
Add-AppveyorMessage -Message 'test message 1' -category 'Warning' -details "This is some details!"

Write-Host "Testing Add-AppveyorCompilationMessage..."
Add-AppveyorCompilationMessage -Message 'test message 1' -category 'Warning' -details "This is some details!" -Line 10 -Column 1

Write-Host "Testing Add-AppveyorTest..."
Add-AppveyorTest -Name "Test A" -Framework "NUnit" -FileName "Assembly1.dll" -Outcome "Running"

Write-Host "Testing Update-AppveyorTest..."
Start-Sleep -s 4
Update-AppveyorTest -Name "Test A" -FileName "Assembly1.dll" -Outcome "Passed" -Duration 1200 -StdOut "This is StdOut" -StdErr "This is StdErr"

Write-Host "Testing Add-AppveyorTestsTest..."
Add-AppveyorTestsTest

Write-Host "Testing Update-AppveyorTestsTest..."
Update-AppveyorTestsTest
