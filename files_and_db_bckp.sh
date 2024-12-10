#!/bin/bash

# -----------------------------------------------
# Skrypt do tworzenia kopii zapasowych baz danych MySQL
# oraz wybranych plików konfiguracyjnych systemu.
# -----------------------------------------------

# Ustawienia

# Główna ścieżka katalogu kopii zapasowych
backup_parent_dir="/home/___backup___/"

# Tworzenie unikalnego katalogu dla bieżącej kopii zapasowej
# Nazwa katalogu zawiera datę i godzinę utworzenia
backup_date=$(date +%Y_%m_%d_%H_%M)
backup_dir="${backup_parent_dir}/${backup_date}"
echo "Katalog kopii zapasowej: ${backup_dir}"

# Tworzenie katalogu oraz ustawienie odpowiednich uprawnień
mkdir -p "${backup_dir}"
chmod 700 "${backup_dir}"

# Tworzenie kopii zapasowych wszystkich baz danych MySQL
# Wartości zmiennych `mysql_user`, `mysql_password` i `mysql_databases` 
# należy zdefiniować przed uruchomieniem skryptu.
for database in $mysql_databases
do
  # Pomijanie specyficznych baz danych systemowych
  # oraz dodawanie odpowiednich parametrów do mysqldump
  if [ "${database}" == "information_schema" ] || [ "${database}" == "performance_schema" ]; then
        additional_mysqldump_params="--skip-lock-tables"
  else
        additional_mysqldump_params=""
  fi

  # Tworzenie kopii zapasowej pojedynczej bazy danych
  echo "Tworzę kopię zapasową bazy danych \"${database}\""
  mysqldump ${additional_mysqldump_params} --user=${mysql_user} --password=${mysql_password} ${database} | gzip > "${backup_dir}/${database}.gz"
  
  # Ustawienie odpowiednich uprawnień dla plików kopii zapasowej
  chmod 600 "${backup_dir}/${database}.gz"
done

# Tworzenie kopii zapasowych wybranych plików konfiguracyjnych systemu
# Kopiowane są pliki związane z konfiguracją użytkowników, grup i Samby
echo "Kopiuję pliki konfiguracyjne do katalogu kopii zapasowej"
cp /etc/samba/smb.conf "${backup_dir}"
cp /etc/group "${backup_dir}"
cp /etc/group- "${backup_dir}"
cp /etc/gshadow "${backup_dir}"
cp /etc/gshadow- "${backup_dir}"
cp /etc/passwd "${backup_dir}"
cp /etc/passwd- "${backup_dir}"
cp /etc/shadow "${backup_dir}"
cp /etc/shadow- "${backup_dir}"

echo "Kopia zapasowa zakończona pomyślnie!"
