$pillStart = [char]0xE0B6
$pillEnd = [char]0xE0B4
$admin = [char]0xF0E7
$branch = [char]0xE0A0
$unstaged = [char]0xF044
$staged = [char]0xF046
$stash = [char]0xEB4B
$prompt = [char]0x276F
$ahead = [char]0x2191
$behind = [char]0x2193

Write-Host ""
Write-Host "Prompt legend" -ForegroundColor White
Write-Host "-------------" -ForegroundColor DarkGray
Write-Host "$pillStart  $pillEnd  segment start/end caps for the rounded pills" -ForegroundColor Gray
Write-Host "$admin      Administrator / elevated shell" -ForegroundColor Red
Write-Host "$branch      current git branch" -ForegroundColor Green
Write-Host "${ahead}N     commits ahead of upstream" -ForegroundColor Magenta
Write-Host "${behind}N     commits behind upstream" -ForegroundColor Magenta
Write-Host "$unstaged N    unstaged working tree changes" -ForegroundColor Yellow
Write-Host "$staged N    staged changes" -ForegroundColor Cyan
Write-Host "$stash N    stash count (only shows when nonzero)" -ForegroundColor Blue
Write-Host "|      separator between unstaged and staged counts" -ForegroundColor DarkGray
Write-Host ".venv  active Python virtual environment name" -ForegroundColor DarkGray
Write-Host "$prompt      prompt marker; white normally, red after a failing command" -ForegroundColor White
Write-Host ""