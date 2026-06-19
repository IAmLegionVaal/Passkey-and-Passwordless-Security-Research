#requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$InputCsv,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Passwordless_Security_Research'}
New-Item -Path $OutputPath -ItemType Directory -Force|Out-Null
if(-not(Test-Path $InputCsv)){Write-Error 'Input CSV not found.';return}
$rows=Import-Csv $InputCsv|ForEach-Object{
 $score=0
 if($_.PhishingResistant -match 'Yes|True'){$score+=25}
 if($_.ManagedDeviceRequired -match 'Yes|True'){$score+=15}
 if($_.RecoveryDocumented -match 'Yes|True'){$score+=20}
 if($_.BreakGlassAvailable -match 'Yes|True'){$score+=15}
 if($_.AuditLogging -match 'Yes|True'){$score+=15}
 if($_.UserTraining -match 'Yes|True'){$score+=10}
 [PSCustomObject]@{SystemName=$_.SystemName;Owner=$_.Owner;PasswordlessMethod=$_.PasswordlessMethod;PhishingResistant=$_.PhishingResistant;ManagedDeviceRequired=$_.ManagedDeviceRequired;RecoveryDocumented=$_.RecoveryDocumented;BreakGlassAvailable=$_.BreakGlassAvailable;AuditLogging=$_.AuditLogging;UserTraining=$_.UserTraining;ReadinessScore=$score;ReadinessBand=$(if($score -ge 80){'Strong'}elseif($score -ge 50){'Developing'}else{'Gap'});Notes=$_.Notes}
}
$byMethod=$rows|Group-Object PasswordlessMethod|ForEach-Object{[PSCustomObject]@{Method=$_.Name;Systems=$_.Count;AverageScore=[math]::Round((($_.Group.ReadinessScore|Measure-Object -Average).Average),1)}}
$gaps=$rows|Where-Object ReadinessBand -ne 'Strong'|Select-Object SystemName,Owner,PasswordlessMethod,PhishingResistant,RecoveryDocumented,BreakGlassAvailable,AuditLogging,UserTraining,ReadinessScore,ReadinessBand
$summary=[PSCustomObject]@{Systems=@($rows).Count;Strong=@($rows|Where-Object ReadinessBand -eq 'Strong').Count;Developing=@($rows|Where-Object ReadinessBand -eq 'Developing').Count;Gaps=@($rows|Where-Object ReadinessBand -eq 'Gap').Count;AverageScore=[math]::Round((($rows.ReadinessScore|Measure-Object -Average).Average),1);Generated=Get-Date}
$rows|Export-Csv (Join-Path $OutputPath "passwordless_register_$stamp.csv") -NoTypeInformation -Encoding UTF8
$byMethod|Export-Csv (Join-Path $OutputPath "method_summary_$stamp.csv") -NoTypeInformation -Encoding UTF8
$gaps|Export-Csv (Join-Path $OutputPath "readiness_gaps_$stamp.csv") -NoTypeInformation -Encoding UTF8
@{Summary=$summary;Systems=$rows;MethodSummary=$byMethod;Gaps=$gaps}|ConvertTo-Json -Depth 8|Set-Content (Join-Path $OutputPath "passwordless_research_$stamp.json") -Encoding UTF8
$html="<h1>Passkey and Passwordless Security Research</h1><p>Generated $(Get-Date)</p><h2>Summary</h2>$(@($summary)|ConvertTo-Html -Fragment)<h2>Method Summary</h2>$($byMethod|ConvertTo-Html -Fragment)<h2>Readiness Gaps</h2>$($gaps|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'Passkey and Passwordless Security Research'|Set-Content (Join-Path $OutputPath "passwordless_research_$stamp.html") -Encoding UTF8
$summary|Format-List
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
