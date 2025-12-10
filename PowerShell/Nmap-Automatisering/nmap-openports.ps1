# nmap-openports.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$Target
)

Write-Host "Kører Nmap scanning på $Target..." -ForegroundColor Cyan

# Kør nmap og filtrer kun åbne porte
$nmapPath = "/usr/local/bin/nmap"  # Skift til din sti

$nmapResult = & $nmapPath -p- $Target | Select-String "open"


if ($nmapResult) {
    Write-Host "`nÅbne porte fundet:" -ForegroundColor Green
    $nmapResult
} else {
    Write-Host "`nIngen åbne porte fundet." -ForegroundColor Yellow
}
