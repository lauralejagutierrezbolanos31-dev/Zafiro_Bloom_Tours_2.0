$pgbin = "C:\Program Files\PostgreSQL\18\bin"
$neon = (Get-Content "database\.neon_url" -Raw).Trim()
$archivo = "database\copia_local.sql"

& "$pgbin\pg_dump.exe" -h localhost -U postgres -d zafiro_bloom_tours_V2 --no-owner --no-privileges --clean --if-exists -f $archivo
if ($LASTEXITCODE -ne 0) { Write-Host "Falló la exportación desde local"; exit 1 }

& "$pgbin\psql.exe" $neon -f $archivo
Write-Host "Neon actualizado con los datos de tu Postgres local."