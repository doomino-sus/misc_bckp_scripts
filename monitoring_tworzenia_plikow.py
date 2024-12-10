import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import date, datetime, timedelta
import time

# Opis skryptu:
# Ten skrypt monitoruje określone ścieżki sieciowe w poszukiwaniu nowych plików lub folderów, które zostały
# zmodyfikowane w bieżącym dniu. Jeżeli znajdzie takie elementy, generuje raport w formacie HTML 
# i wysyła go na podany adres e-mail. Skrypt jest zaprojektowany do uruchamiania jako proces ciągły,
# który co dzień o godzinie 9:00 wykonuje sprawdzenie.

def convert_bytes_to_mb(bytes_size):
    """
    Konwertuje rozmiar pliku z bajtów na megabajty (MB).
    :param bytes_size: Rozmiar w bajtach.
    :return: Rozmiar w MB zaokrąglony do dwóch miejsc po przecinku.
    """
    mb_size = bytes_size / (1024 * 1024)
    return round(mb_size, 2)

def check_files_and_send_email(check_date):
    """
    Sprawdza pliki i foldery w określonych ścieżkach oraz wysyła raport na e-mail.
    :param check_date: Data, dla której sprawdzane są pliki.
    """
    # Ścieżki do sprawdzenia (wprowadź swoje własne ścieżki)
    paths_to_check = [
        {"title": "Backup 1", "path": r"\\server\path\backup1"},
        {"title": "Backup 2", "path": r"\\server\path\backup2"},
        {"title": "Backup 3", "path": r"\\server\path\backup3"}
    ]

    # Data w formacie YYYY-MM-DD
    today = check_date.strftime("%Y-%m-%d")

    # Tworzenie wiadomości e-mail
    message = MIMEMultipart()
    message['From'] = 'your_email@example.com'  # Twój adres e-mail
    message['To'] = 'recipient_email@example.com'  # Adres odbiorcy
    message['Subject'] = f'Report - Backup Check - {today}'

    body = '<html><body>Files found:<br><br>'
    files_found = False

    # Przetwarzanie każdej ścieżki
    for path_info in paths_to_check:
        title = path_info["title"]
        path = path_info["path"]
        body += f'<strong>{title}:</strong><br>'

        if os.path.exists(path):
            entries = os.listdir(path)
            sorted_entries = sorted(entries)

            for entry in sorted_entries:
                entry_path = os.path.join(path, entry)

                # Sprawdzenie plików
                if os.path.isfile(entry_path) and entry != "backup.log":
                    modification_time = os.path.getmtime(entry_path)
                    modification_date = datetime.fromtimestamp(modification_time).date()

                    if modification_date == check_date:
                        file_size = os.path.getsize(entry_path)
                        file_size_mb = convert_bytes_to_mb(file_size)
                        body += f'Path: {path} | File: <b>{entry}</b> | Modification Date: <b>{modification_date}</b> | Size: <b>{file_size_mb} MB</b><br>'
                        files_found = True

                # Sprawdzenie folderów
                elif os.path.isdir(entry_path):
                    modification_time = os.path.getmtime(entry_path)
                    modification_date = datetime.fromtimestamp(modification_time).date()

                    if modification_date == check_date:
                        body += f'Folder: {entry_path} | Modification Date: <b>{modification_date}</b><br>'
                        files_found = True

        body += '<br>'

    # Dodanie informacji, gdy brak nowych plików
    if not files_found:
        body += 'No new files or directories found today.'

    body += '</body></html>'

    # Załącznik treści e-maila
    message.attach(MIMEText(body, 'html'))

    # Wysyłanie wiadomości e-mail
    with smtplib.SMTP_SSL('smtp.example.com', 465) as server:  # SMTP serwer (placeholder)
        server.login('your_email@example.com', 'your_password')  # Login (placeholder)
        server.sendmail('your_email@example.com', 'recipient_email@example.com', message.as_string())

def run_daily_check():
    """
    Uruchamia pętlę, która codziennie o godzinie 9:00 wykonuje sprawdzenie plików i wysyła raport e-mail.
    """
    while True:
        # Oblicz czas następnego sprawdzenia (dzisiaj o 9:00 lub jutro o 9:00)
        now = datetime.now()
        today_nine_am = datetime.combine(now.date(), datetime.strptime('9:00', '%H:%M').time())

        if now < today_nine_am:
            next_check_datetime = today_nine_am
        else:
            tomorrow = now.date() + timedelta(days=1)
            next_check_datetime = datetime.combine(tomorrow, datetime.strptime('9:00', '%H:%M').time())

        # Czas do oczekiwania na następne sprawdzenie
        time_difference = next_check_datetime - now
        seconds_to_wait = time_difference.total_seconds()

        # Oczekiwanie
        time.sleep(seconds_to_wait)

        # Sprawdzanie plików i wysyłanie raportu
        today = date.today()
        check_files_and_send_email(today)

if __name__ == "__main__":
    run_daily_check()
