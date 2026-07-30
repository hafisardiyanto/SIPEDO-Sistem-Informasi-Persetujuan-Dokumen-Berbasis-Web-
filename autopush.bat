@echo off
echo ==================================================
echo   🚀 SIPEDO AUTOMATIC GIT PUSH SCRIPT (Win)
echo ==================================================
echo.

:: Meminta pesan komit dari pengguna
set /p commit_msg="Masukkan pesan commit: "

:: Menambahkan semua file yang berubah
echo [1/3] Menyiapkan perubahan file (git add .)...
git add .

:: Melakukan commit 
echo [2/3] Menyimpan snapshot kode (git commit)...
git commit -m "%commit_msg%"

:: Melakukan dorongan ke remote (push)
:: Catatan: Jika sudah di-setting multi-remote, ini akan terlempar ke Github & Gitlab sekaligus
echo [3/3] Meluncurkan data ke repositori cloud (git push)...
git push

echo.
echo ==================================================
echo   ✅ PROSES SELESAI! KODE TERBARU SUDAH ONLINE.
echo ==================================================
pause
