@echo off
:: Pobranie bieżącej daty w formacie YYYY-MM-DD
for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined MyDate set MyDate=%%x
for /f %%x in ('wmic path win32_localtime get /format:list ^| findstr "="') do set %%x
set fmonth=00%Month%
set fday=00%Day%
set today=%Year%-%fmonth:~-2%-%fday:~-2%

:: Tworzenie katalogu dla kopii zapasowej (opcjonalne, zakomentowane)
:: md X:\backup_folder\%today%

:: Tworzenie kopii zapasowej bazy danych
echo Tworzę kopię zapasową bazy danych
sqlcmd -S server_name\instance_name -U username -P "password" -Q "BACKUP DATABASE database_name TO DISK = 'C:\TempBackup.bak' WITH NAME = 'DatabaseBackup', FORMAT"

:: Przenoszenie kopii zapasowej do archiwum
echo Przenoszę kopię zapasową do katalogu archiwum
move C:\TempBackup.bak "X:\backup_folder\DatabaseBackup_%today%.bak"

echo Kopia zapasowa została wykonana poprawnie
