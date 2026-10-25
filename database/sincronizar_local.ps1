$pgbin = "C:\Program Files\PostgreSQL\18\bin"
$neon = Read-Host "Pega la URL DIRECTA de Neon (sin -pooler)"
$archivo = "database\copia_neon.sql"

& "$pgbin\pg_dump.exe" $neon --no-owner --no-privileges --clean --if-exists -f $archivo
if ($LASTEXITCODE -ne 0) { Write-Host "Falló la exportación desde Neon"; exit 1 }

& "$pgbin\psql.exe" -h localhost -U postgres -d zafiro_bloom_tours_V2 -f $archivo
Write-Host "Copia terminada."