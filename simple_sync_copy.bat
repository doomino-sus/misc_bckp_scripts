@echo off
:: Ustawienie kodowania na UTF-8
chcp 65001
:: ewentualnie zamienić na chcp 65000

:: Usunięcie istniejących mapowań dysków sieciowych
net use x: /delete /y
net use y: /delete /y
net use z: /delete /y

:: Mapowanie udziałów sieciowych do dysków
net use x: \\server_name\client_share
net use y: \\server_name\training_share
net use z: \\server_name\hr_share

:: Kopiowanie danych z mapowanych dysków sieciowych do lokalnych katalogów przy użyciu robocopy
:: Opcje:
:: /MIR - Tworzenie lustrzanej kopii (usuwanie plików, które nie istnieją w źródle)
:: /UNILOG+ - Zapisywanie szczegółowego logu z operacji do pliku z aktualną datą
:: /TEE - Wyświetlanie logu w konsoli i zapisywanie go do pliku
:: /NP - Nie wyświetla postępu w logach
:: /NDL - Nie wyświetla nazw katalogów w logach
:: /X - Zapisuje informację o wykluczonych plikach
:: /W:1 - Czas oczekiwania (1 sekunda) przed ponowną próbą
:: /R:3 - Liczba prób w przypadku błędu (3 próby)
robocopy x:\ local_path\client_data\ /MIR /UNILOG+:"local_path\logs\%date%-client_data.log" /TEE /NP /NDL /X /W:1 /R:3
robocopy y:\ local_path\training_data\ /MIR /UNILOG+:"local_path\logs\%date%-training_data.log" /TEE /NP /NDL /X /W:1 /R:3
robocopy z:\ local_path\hr_data\ /MIR /UNILOG+:"local_path\logs\%date%-hr_data.log" /TEE /NP /NDL /X /W:1 /R:3
