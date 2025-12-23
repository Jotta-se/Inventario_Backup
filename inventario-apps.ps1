# Script de Inventário Completo de Aplicativos Windows
# Executa como Administrador para melhores resultados

# Define o diretório de backup
$backupPath = "C:\Backup-Apps-$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Force -Path $backupPath | Out-Null

Write-Host "=== INVENTÁRIO DE APLICATIVOS WINDOWS ===" -ForegroundColor Cyan
Write-Host "Salvando em: $backupPath`n" -ForegroundColor Yellow

# 1. EXPORTAR LISTA DO WINGET
Write-Host "[1/7] Exportando aplicativos do Winget..." -ForegroundColor Green
try {
    winget export -o "$backupPath\winget-apps.json" --accept-source-agreements
    Write-Host "✓ Winget exportado com sucesso" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro ao exportar Winget (pode não estar instalado)" -ForegroundColor Red
}

# 2. PROGRAMAS INSTALADOS (Win32 - 64 bits)
Write-Host "`n[2/7] Listando programas Win32 (64-bit)..." -ForegroundColor Green
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation |
    Export-Csv "$backupPath\programas-64bit.csv" -NoTypeInformation -Encoding UTF8
Write-Host "✓ Lista de programas 64-bit salva" -ForegroundColor Green

# 3. PROGRAMAS INSTALADOS (Win32 - 32 bits)
Write-Host "`n[3/7] Listando programas Win32 (32-bit)..." -ForegroundColor Green
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation |
    Export-Csv "$backupPath\programas-32bit.csv" -NoTypeInformation -Encoding UTF8
Write-Host "✓ Lista de programas 32-bit salva" -ForegroundColor Green

# 4. APPS DA MICROSOFT STORE
Write-Host "`n[4/7] Listando apps da Microsoft Store..." -ForegroundColor Green
Get-AppxPackage |
    Select-Object Name, PackageFullName, Version, Publisher |
    Export-Csv "$backupPath\store-apps.csv" -NoTypeInformation -Encoding UTF8
Write-Host "✓ Lista de apps da Store salva" -ForegroundColor Green

# 5. PROGRAMAS DO USUÁRIO ATUAL
Write-Host "`n[5/7] Listando programas do usuário atual..." -ForegroundColor Green
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Export-Csv "$backupPath\programas-usuario.csv" -NoTypeInformation -Encoding UTF8
Write-Host "✓ Lista de programas do usuário salva" -ForegroundColor Green

# 6. LISTA CONSOLIDADA EM TXT (FÁCIL LEITURA)
Write-Host "`n[6/7] Criando lista consolidada legível..." -ForegroundColor Green

$txtReport = @"
======================================================
INVENTÁRIO DE APLICATIVOS - $(Get-Date -Format 'dd/MM/yyyy HH:mm')
======================================================

PROGRAMAS INSTALADOS (Win32):
------------------------------
"@

$allPrograms = @()
$allPrograms += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName }
$allPrograms += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName }

$allPrograms | Sort-Object DisplayName -Unique | ForEach-Object {
    $txtReport += "`n• $($_.DisplayName)"
    if ($_.DisplayVersion) {
        $txtReport += " (v$($_.DisplayVersion))"
    }
    if ($_.Publisher) {
        $txtReport += " - $($_.Publisher)"
    }
}

$txtReport += "`n`n`nAPPS DA MICROSOFT STORE:"
$txtReport += "`n------------------------------"

Get-AppxPackage | Sort-Object Name | ForEach-Object {
    $txtReport += "`n• $($_.Name) (v$($_.Version))"
}

$txtReport | Out-File "$backupPath\LISTA-COMPLETA.txt" -Encoding UTF8
Write-Host "✓ Lista consolidada criada" -ForegroundColor Green

# 7. CRIAR SCRIPT DE REINSTALAÇÃO
Write-Host "`n[7/7] Criando script de reinstalação..." -ForegroundColor Green

$reinstallScript = @'
# SCRIPT DE REINSTALAÇÃO AUTOMÁTICA
# Execute como Administrador após formatar o Windows

Write-Host "=== REINSTALAÇÃO DE APLICATIVOS ===" -ForegroundColor Cyan

# 1. Reinstalar via Winget
if (Test-Path ".\winget-apps.json") {
    Write-Host "`nInstalando aplicativos do Winget..." -ForegroundColor Yellow
    winget import -i ".\winget-apps.json" --accept-source-agreements --accept-package-agreements
} else {
    Write-Host "Arquivo winget-apps.json não encontrado" -ForegroundColor Red
}

# 2. Reinstalar apps da Store (requer login na Microsoft Store)
Write-Host "`nPara apps da Store, consulte o arquivo store-apps.csv" -ForegroundColor Yellow
Write-Host "Você precisará reinstalá-los manualmente pela Microsoft Store" -ForegroundColor Yellow

# 3. Lista de programas para instalação manual
Write-Host "`nConsulte os arquivos CSV para programas que precisam instalação manual:" -ForegroundColor Yellow
Write-Host "  • programas-64bit.csv" -ForegroundColor White
Write-Host "  • programas-32bit.csv" -ForegroundColor White
Write-Host "  • programas-usuario.csv" -ForegroundColor White

Write-Host "`nReinstalação via Winget concluída!" -ForegroundColor Green
Write-Host "Verifique os arquivos CSV para programas adicionais." -ForegroundColor Green

Read-Host "`nPressione Enter para sair"
'@

$reinstallScript | Out-File "$backupPath\REINSTALAR.ps1" -Encoding UTF8
Write-Host "✓ Script de reinstalação criado" -ForegroundColor Green

# RESUMO FINAL
Write-Host "`n`n======================================================" -ForegroundColor Cyan
Write-Host "INVENTÁRIO CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "`nArquivos criados em: $backupPath" -ForegroundColor Yellow
Write-Host "`nArquivos gerados:" -ForegroundColor White
Write-Host "  1. winget-apps.json          - Apps para reinstalar automaticamente" -ForegroundColor White
Write-Host "  2. programas-64bit.csv       - Programas Win32 64-bit" -ForegroundColor White
Write-Host "  3. programas-32bit.csv       - Programas Win32 32-bit" -ForegroundColor White
Write-Host "  4. programas-usuario.csv     - Programas do usuário" -ForegroundColor White
Write-Host "  5. store-apps.csv            - Apps da Microsoft Store" -ForegroundColor White
Write-Host "  6. LISTA-COMPLETA.txt        - Lista legível de tudo" -ForegroundColor White
Write-Host "  7. REINSTALAR.ps1            - Script de reinstalação" -ForegroundColor White

Write-Host "`n⚠ IMPORTANTE:" -ForegroundColor Yellow
Write-Host "  • Copie a pasta '$backupPath' para um HD externo ou nuvem" -ForegroundColor White
Write-Host "  • Salve também suas licenças e configurações importantes" -ForegroundColor White
Write-Host "  • Após formatar, execute REINSTALAR.ps1 como Administrador" -ForegroundColor White

Write-Host "`n======================================================`n" -ForegroundColor Cyan

# Tentar abrir a pasta
try {
    explorer $backupPath
} catch {}

Read-Host "Pressione Enter para sair"
