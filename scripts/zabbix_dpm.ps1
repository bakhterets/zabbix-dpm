<#
Get dpm alerts
Version 1.0

Description: DPM monitoring script.

Ilia Bakhterev
bakhterets@gmail.com
#>
# Options
[CmdletBinding()]
param (
    [Parameter(Position=0, Mandatory=$True)]
    [ValidateSet('ExportDPMAlerts','DiscoveryAlerts','GetAlertInfo')]
    [string]
    $Action,
    [Parameter(Position=1, Mandatory=$False)]
    [string]
    $AlertID,
    [Parameter(Position=2, Mandatory=$False)]
    [string]
    $Parameter
)
    if ($PSBoundParameters.Verbose) {$VerbosePreference = "Continue"}
    if ($PSBoundParameters.Debug) {$DebugPreference = "Continue"}

# Function ExportCliXml
function ExportDPMAlerts {
    $hostname = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
    Get-DPMAlert -DPMServerName "$hostname"  | Export-Clixml -Path "$PSScriptRoot\AlertsDPM.xml" -Force
}
# Function "Discovery"
function DiscoveryAlerts {
    $AlertIDs = (Import-Clixml -Path "$PSScriptRoot\AlertsDPM.xml").AlertID
    ConvertTo-Json @{"data"=[array]($AlertIDs) | Select-Object @{l="{#ALERTID}";e={$_.Guid}}}
}
# Function "GetAlertInfo"
function GetAlertInfo {
    $AlertInfo = (Import-Clixml -Path "$PSScriptRoot\AlertsDPM.xml" | Where-Object {$_.AlertID -eq "$AlertID"})
    if ($Parameter -eq "ErrorInfo") {
        $AlertInfo.ErrorInfo.Problem.ToString()
    } elseif ($Parameter -eq "IsResolved") {
        if ($AlertInfo.$Parameter -eq $True) {
            $True
        } else {
            $False
        }
    } elseif ($Parameter -eq "Datasource") {
        $AlertInfo.$Parameter.ToString()
    } elseif ($Parameter -eq "DatasourceID") {
        $AlertInfo.$Parameter.ToString()
    } elseif ($Parameter -eq "Resolution") {
        $AlertInfo.$Parameter.ToString()
    } elseif ($Parameter -eq "Severity") {
        switch ($AlertInfo.$Parameter.ToString()) {
            "Information" { 0 }
            "Warning" { 1 }
            "Error" { 2 }
            Default { 3 }
        }
    } elseif ($Parameter -eq "Type") {
        $AlertInfo.$Parameter.ToString()
    } elseif ($Parameter -eq "OccurredSince") {
        (Get-Date $AlertInfo.$Parameter -Format "dd-MM-yyyy HH:mm:ss")
    } elseif ($Parameter -eq "ResolvedDateTime") {
        (Get-Date $AlertInfo.$Parameter -Format "dd-MM-yyyy HH:mm:ss")
    } else {
        $AlertInfo.$Parameter
    }
}
## switch functions
switch ($Action) {
    ExportDPMAlerts { ExportDPMAlerts }
    DiscoveryAlerts { DiscoveryAlerts }
    GetAlertInfo { GetAlertInfo }
    Default {"!Some error!"}
}