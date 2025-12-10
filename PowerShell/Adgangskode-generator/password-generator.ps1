# password-generator.ps1

param(
    [int]$Length = 16
)

# Tegn-pools
$upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$lower = "abcdefghijklmnopqrstuvwxyz"
$numbers = "0123456789"
$symbols = "!@#$%^&*()_-+=<>?/{}[]|"

# Samlet pool
$allChars = $upper + $lower + $numbers + $symbols

# Random generator
$rand = New-Object System.Random

$password = ""

for ($i = 0; $i -lt $Length; $i++) {
    $password += $allChars[$rand.Next(0, $allChars.Length)]
}

Write-Host "Genereret adgangskode:" -ForegroundColor Cyan
Write-Host $password
