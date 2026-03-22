# ============================================================
# deploy_lina.ps1
# Descomprime el ZIP de Claude y copia los archivos al proyecto LINA.
#
# USO:
#   PowerShell -ExecutionPolicy Bypass -File "D:\desarrollo_web\lina_web\deploy_lina.ps1"
# ============================================================

# ── Configuración ──────────────────────────────────────────
$ZipFile     = "D:\Doc-JCM\Downloads\files.zip"
$ZipTemp     = "D:\Doc-JCM\Downloads\files_extracted"
$ProjectRoot = "D:\desarrollo_web\lina_web"
# ──────────────────────────────────────────────────────────

$files = @{
    "static\css\lina_base.css"               = "static\css\lina_base.css"
    "static\js\lina_base_core.js"            = "static\js\lina_base_core.js"
    "static\js\lina_base_session.js"         = "static\js\lina_base_session.js"
    "templates\base.html"                    = "templates\base.html"
    "templates\program.html"                 = "templates\program.html"
    "templates\partials\_permisos.html"      = "templates\partials\_permisos.html"
    "templates\fragments\program_error.html" = "templates\fragments\program_error.html"
    "templates\lina111\form.html"            = "templates\lina111\form.html"
    "templates\lina111\grid.html"            = "templates\lina111\grid.html"
    "templates\lina111\main.html"            = "templates\lina111\main.html"
    "templates\lina131\grid.html"            = "templates\lina131\grid.html"
    "templates\lina131\main.html"            = "templates\lina131\main.html"
}

if (-not (Test-Path $ZipFile))     { Write-Error "No se encontro: $ZipFile"; exit 1 }
if (-not (Test-Path $ProjectRoot)) { Write-Error "No se encontro: $ProjectRoot"; exit 1 }

# Descomprimir
Write-Host "Descomprimiendo $ZipFile ..."
if (Test-Path $ZipTemp) { Remove-Item -Path $ZipTemp -Recurse -Force }
Expand-Archive -Path $ZipFile -DestinationPath $ZipTemp -Force

# Buscar la carpeta que contiene los archivos buscando 'static' o 'templates'
# El ZIP tiene estructura: mnt\user-data\outputs\static y mnt\user-data\outputs\templates
$ZipRoot = Get-ChildItem -Path $ZipTemp -Recurse -Directory |
    Where-Object { (Test-Path (Join-Path $_.FullName "static")) -or (Test-Path (Join-Path $_.FullName "templates")) } |
    Select-Object -First 1

if (-not $ZipRoot) {
    Write-Error "No se encontro la carpeta con static\ o templates\ dentro del ZIP."
    Remove-Item -Path $ZipTemp -Recurse -Force
    exit 1
}

$ZipRoot = $ZipRoot.FullName
Write-Host "Raiz de archivos: $ZipRoot"
Write-Host ""

# Copiar archivos
$countOk  = 0
$countErr = 0

foreach ($entry in $files.GetEnumerator()) {
    $src = Join-Path $ZipRoot     $entry.Key
    $dst = Join-Path $ProjectRoot $entry.Value
    $dir = Split-Path $dst

    if (-not (Test-Path $src)) {
        Write-Warning "FALTANTE: $($entry.Key)"
        $countErr++
        continue
    }

    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    if (Test-Path $dst) {
        Copy-Item -Path $dst -Destination "$dst.bak" -Force
    }

    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "OK  $($entry.Value)"
    $countOk++
}

Remove-Item -Path $ZipTemp -Recurse -Force
Write-Host ""
Write-Host "==================================="
Write-Host "  Copiados : $countOk"
Write-Host "  Faltantes: $countErr"
Write-Host "==================================="

if ($countErr -eq 0) {
    Write-Host "Listo. Reinicia uvicorn para aplicar los cambios." -ForegroundColor Green
} else {
    Write-Host "Algunos archivos no se encontraron. Verifica el ZIP." -ForegroundColor Yellow
}
