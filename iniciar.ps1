$raiz = $PSScriptRoot

# --- Backend ---
Set-Location "$raiz\backend"
if (-not (Test-Path "venv")) { python -m venv venv }
& .\venv\Scripts\python.exe -m pip install -r requirements.txt -q
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Se creó backend\.env. Pega la URL de Neon, guarda y vuelve a ejecutar." -ForegroundColor Yellow
    notepad .env
    exit
}

# --- Frontend ---
Set-Location "$raiz\frontend"
if (-not (Test-Path ".env")) { Copy-Item ".env.example" ".env" }
if (-not (Test-Path "node_modules")) { npm install }

# --- Arrancar los dos ---
Start-Process powershell -ArgumentList "-NoExit","-Command","cd '$raiz\backend'; .\venv\Scripts\python.exe -m uvicorn app.main:app --reload"
Start-Process powershell -ArgumentList "-NoExit","-Command","cd '$raiz\frontend'; npm run dev"
Write-Host "Listo. Abre http://localhost:5173" -ForegroundColor Green