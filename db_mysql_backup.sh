#!/bin/bash
# ---------------------------------------------------------
# Skrypt do tworzenia kopii zapasowych baz danych MySQL.
# ---------------------------------------------------------

# Ustawienia

# Główna ścieżka katalogu kopii zapasowych
backup_parent_dir="/home/mysql-backup/"

# Ustawienia MySQL: użytkownik i hasło
mysql_user="user"
mysql_password="pass"

# -------------------------------------------
# Sprawdzenie, czy hasło MySQL zostało podane.
# Jeżeli nie, skrypt poprosi o wprowadzenie hasła.
# -------------------------------------------
if [ -z "${mysql_password}" ]; then
  echo -n "Enter MySQL ${mysql_user} password: "
  read -s mysql_password
  echo
fi

# -------------------------------------------
# Weryfikacja poprawności hasła MySQL.
# Skrypt próbuje się połączyć z MySQL, aby upewnić się,
# że podane hasło jest poprawne.
# -------------------------------------------
echo exit | mysql --user=${mysql_user} --password=${mysql_password} -B 2>/dev/null
if [ "$?" -gt 0 ]; then
  echo "MySQL ${mysql_user} password incorrect"
  exit 1
else
  echo "MySQL ${mysql_user} password correct."
fi

# -------------------------------------------
# Tworzenie katalogu na kopie zapasowe.
# Tworzymy unikalny katalog na podstawie daty i godziny.
# Ustawiamy odpowiednie uprawnienia do katalogu.
# -------------------------------------------
backup_date=`date +%Y_%m_%d_%H_%M`
backup_dir="${backup_parent_dir}/${backup_date}"
echo "Katalog kopii zapasowej: ${backup_dir}"
mkdir -p "${backup_dir}"
chmod 700 "${backup_dir}"

# -------------------------------------------
# Pobranie listy dostępnych baz danych MySQL.
# Skrypt generuje listę baz danych, którą następnie 
# wykorzysta do wykonania kopii zapasowych.
# -------------------------------------------
mysql_databases=`echo 'show databases' | mysql --user=${mysql_user} --password=${mysql_password} -B | sed /^Database$/d`

# -------------------------------------------
# Tworzenie kopii zapasowych dla każdej bazy danych.
# Skrypt wykonuje kopię zapasową każdej bazy, kompresując
# plik kopii przy użyciu gzip. Kopie zapasowe są zapisane w
# katalogu, który został utworzony wcześniej.
# -------------------------------------------
for database in $mysql_databases
do
  # Pomijanie baz systemowych, które nie powinny być kopiowane
  # Dodanie odpowiednich parametrów do mysqldump, aby uniknąć błędów
  if [ "${database}" == "information_schema" ] || [ "${database}" == "performance_schema" ]; then
        additional_mysqldump_params="--skip-lock-tables"
  else
        additional_mysqldump_params=""
  fi

  # Tworzenie kopii zapasowej bazy danych
  echo "Tworzę kopię zapasową bazy danych \"${database}\""
  mysqldump ${additional_mysqldump_params} --user=${mysql_user} --password=${mysql_password} ${database} | gzip > "${backup_dir}/${database}.gz"
  
  # Ustawienie odpowiednich uprawnień do pliku kopii zapasowej
  chmod 600 "${backup_dir}/${database}.gz"
done

echo "Kopia zapasowa zakończona pomyślnie!"
