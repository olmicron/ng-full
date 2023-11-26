# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

#### Ответ

```shell
docker run -d \
--name mysql \
-e MYSQL_ROOT_PASSWORD=qqqqqq \
-v /.docker-data/mysql/data:/var/lib/mysql \
-v /.docker-data/mysql/backup:/tmp/backup \
mysql:8.2.0
```
Директорию с бэкапом использовал для того, чтобы передать в контейнер данные (test_dump.sql).

Далее вхожу в контейнер и восстанавливаю БД:
```shell
docker exec -it mysql /bin/bash
mysql -e "create database test_db;"
mysql --password=qqqqqq test_db < /tmp/backup/test_dump.sql
```

И далее запускаю утилиту `mysql` и вывожу статус БД (целиком):
```shell
mysql --password=qqqqqq

mysql> \s
--------------
mysql  Ver 8.2.0 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          17
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.2.0 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 7 hours 36 min 23 sec

Threads: 3  Questions: 87  Slow queries: 0  Opens: 636  Flush tables: 6  Open tables: 42  Queries per second avg: 0.003
--------------
```

И далее по таблицам:
```shell
mysql> connect test_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Connection id:    21
Current database: test_db

mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

mysql> select count(*) from orders where price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

#### Ответ

```mysql
create user "test" identified 
    with mysql_native_password by "test-pass"
    with max_queries_per_hour 100
    password expire interval 180 day 
    failed_login_attempts 3
    attribute '{"surname": "pretty", "name": "james"}';
Query OK, 0 rows affected (0.01 sec)

grant select on test_db.* to test;
Query OK, 0 rows affected (0.01 sec)

select * from INFORMATION_SCHEMA.USER_ATTRIBUTES where user = "test";
+------+------+----------------------------------------+
| USER | HOST | ATTRIBUTE                              |
+------+------+----------------------------------------+
| test | %    | {"name": "james", "surname": "pretty"} |
+------+------+----------------------------------------+
1 row in set (0.01 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

#### Ответ

```shell
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> SHOW PROFILES;
Empty set, 1 warning (0.00 sec)

mysql> show table status where name = 'orders';
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| Name   | Engine | Version | Row_format | Rows | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free | Auto_increment | Create_time         | Update_time         | Check_time | Collation          | Checksum | Create_options | Comment |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| orders | InnoDB |      10 | Dynamic    |    5 |           3276 |       16384 |               0 |            0 |         0 |              6 | 2023-11-26 20:19:02 | 2023-11-26 20:19:02 | NULL       | utf8mb4_0900_ai_ci |     NULL |                |         |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
1 row in set (0.00 sec)

mysql> alter table orders engine=MyISAM;
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> alter table orders engine=InnoDB;
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+-----------------------------------------+
| Query_ID | Duration   | Query                                   |
+----------+------------+-----------------------------------------+
|        1 | 0.00085325 | show table status where name = 'orders' |
|        2 | 0.02104275 | alter table orders engine=MyISAM        |
|        3 | 0.02489000 | alter table orders engine=InnoDB        |
+----------+------------+-----------------------------------------+
3 rows in set, 1 warning (0.00 sec)
```


## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

#### Ответ

В мойм случае файла `my.cnf` по указанному пути не оказалось. Пришлось воспользоваться поиском:
```shell
find / -name my.cnf
find: '/proc/1/map_files': Permission denied
find: '/proc/406/task/406/net': Invalid argument
find: '/proc/406/net': Invalid argument
/etc/my.cnf
```

Содержимое `/etc/my.cnf` у меня такое:
```ini
[mysqld]
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock
```

В раздел `[mysqld]` добавляем следующие параметры:
```ini
[mysqld]
# Скорость IO важнее сохранности данных:
innodb_flush_method = O_DIRECT
# Нужна компрессия таблиц для экономии места на диске:
innodb_file_per_table = 1
# Размер буффера с незакомиченными транзакциями 1 Мб:
innodb_log_buffer_size = 1M
# Буффер кеширования 30% от ОЗУ,в моём случае 8G * 0.3 = 2.4G:
innodb_buffer_pool_size = 2.4G
# Размер файла логов операций 100 Мб:
innodb_log_file_size = 100M
```

Весь файл целиком уже не буду приводить, думаю и так понятно :)

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
