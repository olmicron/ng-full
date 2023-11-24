# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

#### Ответ

```shell
docker run --name postgres -e POSTGRES_PASSWORD=qqqqqq -d \
-p 5432:5432 \
-v /.docker-data/postgres/data:/var/lib/postgresql/data \
-v /.docker-data/postgres/backup:/tmp/backup \
postgres:12.17
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

#### Ответ

Выполнял следующие команды (внутри утилиты `psql`, которую запустил командой `psql -U postgres`):
```postgresql
create database test_db;
create user "test-admin-user" with password 'qqq';

create table orders (
  id serial primary key,
  name text not null,
  cost int not null 
);

create table clients (
  id serial primary key,
  lastname text not null,
  country text not null,
  order_id int default null,
  foreign key (order_id) references orders (id)
);

create index idx_country on clients using hash (country);

grant all on orders, clients to "test-admin-user";
create user "test-simple-user" with password 'qqq';
grant SELECT,INSERT,UPDATE,DELETE on orders, clients to "test-simple-user";
```

итоговый список БД после выполнения пунктов выше:
```postgresql
\l+
                                                                   List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   |  Size   | Tablespace |                Description                 
-----------+----------+----------+------------+------------+-----------------------+---------+------------+--------------------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |                       | 8169 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +| 7833 kB | pg_default | unmodifiable empty database
           |          |          |            |            | postgres=CTc/postgres |         |            | 
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +| 7833 kB | pg_default | default template for new databases
           |          |          |            |            | postgres=CTc/postgres |         |            | 
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 |                       | 7833 kB | pg_default | 
(4 rows)
```

описание таблиц (describe):
```postgresql
\d orders
                            Table "public.orders"
 Column |  Type   | Collation | Nullable |              Default               
--------+---------+-----------+----------+------------------------------------
 id     | integer |           | not null | nextval('orders_id_seq'::regclass)
 name   | text    |           | not null | 
 cost   | integer |           | not null | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT
    
    
\d clients
                                Table "public.clients"
  Column  |  Type   | Collation | Nullable |                  Default                  
----------+---------+-----------+----------+-------------------------------------------
 id       | integer |           | not null | nextval('clients_id_seq'::regclass)
 lastname | text    |           | not null | 
 country  | text    |           | not null | 
 order_id | integer |           | not null | nextval('clients_order_id_seq'::regclass)
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "idx_country" hash (country)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT
```

SQL-запрос для выдачи списка пользователей с правами над таблицами test_db.

В данном случае вывожу информацию по таблицам != `information_schema` и `pg_catalog`
 хотя, как альтернатива - можно было бы перечислить только нужные таблицы.
```postgresql
SELECT grantee as "User", table_name, privilege_type
FROM information_schema.table_privileges
WHERE table_schema NOT IN ('information_schema','pg_catalog');

--- список пользователей с правами над таблицами test_db ---
       User       | table_name | privilege_type 
------------------+------------+----------------
 postgres         | orders     | INSERT
 postgres         | orders     | SELECT
 postgres         | orders     | UPDATE
 postgres         | orders     | DELETE
 postgres         | orders     | TRUNCATE
 postgres         | orders     | REFERENCES
 postgres         | orders     | TRIGGER
 postgres         | clients    | INSERT
 postgres         | clients    | SELECT
 postgres         | clients    | UPDATE
 postgres         | clients    | DELETE
 postgres         | clients    | TRUNCATE
 postgres         | clients    | REFERENCES
 postgres         | clients    | TRIGGER
 test-admin-user  | orders     | INSERT
 test-admin-user  | orders     | SELECT
 test-admin-user  | orders     | UPDATE
 test-admin-user  | orders     | DELETE
 test-admin-user  | orders     | TRUNCATE
 test-admin-user  | orders     | REFERENCES
 test-admin-user  | orders     | TRIGGER
 test-admin-user  | clients    | INSERT
 test-admin-user  | clients    | SELECT
 test-admin-user  | clients    | UPDATE
 test-admin-user  | clients    | DELETE
 test-admin-user  | clients    | TRUNCATE
 test-admin-user  | clients    | REFERENCES
 test-admin-user  | clients    | TRIGGER
 test-simple-user | orders     | INSERT
 test-simple-user | orders     | SELECT
 test-simple-user | orders     | UPDATE
 test-simple-user | orders     | DELETE
 test-simple-user | clients    | INSERT
 test-simple-user | clients    | SELECT
 test-simple-user | clients    | UPDATE
 test-simple-user | clients    | DELETE
(36 rows)
```


## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

#### Ответ

По `вычислите количество записей для каждой таблицы ` не совсем понятно. Нужно кол-во строк в таблицах после вставки данных, или каким-то образом ДО вставки данных? До - я не смогу, а после - будет ниже.

```postgresql
insert into orders (name, cost) values
('Шоколад', 10),
('Принтер', 3000),
('Книга',   500),
('Монитор', 7000),
('Гитара',  4000);
INSERT 0 5

insert into clients (lastname, country) values
('Иванов Иван Иванович', 'USA'),
('Петров Петр Петрович', 'Canada'),
('Иоганн Себастьян Бах', 'Japan'),
('Ронни Джеймс Дио', 'Russia'),
('Ritchie Blackmore', 'Russia');
INSERT 0 5

select count(*) from clients;
 count 
-------
     5
(1 row)
 
select count(*) from orders;
 count 
-------
     5
(1 row)
```


## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

#### Ответ

Не совсем понятно каким образом их связать (понятно что через update), но их можно связать используя ID строк или имена (книга, монитор, гитара)?
Приведу ответ по именам...

_P.S. Только сейчас заметил, что в задании 1 указано, что в clients будет колонка с фамилией, а в остальных заданиях данные в виде ФИО. Колонку переименовывать в более подходящее название уже не стал._

Приведите SQL-запросы для выполнения данных операций: 

```postgresql
update clients
set order_id = (select id from orders where name like 'Книга')
where lastname = 'Иванов Иван Иванович';

update clients
set order_id = (select id from orders where name like 'Монитор')
where lastname = 'Петров Петр Петрович';

update clients
set order_id = (select id from orders where name like 'Гитара')
where lastname = 'Иоганн Себастьян Бах';
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса:

```postgresql
select * from clients where order_id notnull;

 id |       lastname       | country | order_id 
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(3 rows)

```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

#### Ответ

```postgresql
explain select * from clients where order_id notnull;

                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..18.10 rows=806 width=72)
   Filter: (order_id IS NOT NULL)
(2 rows)
```

Тут видно, что осуществляется последовательное чтение данных из таблицы "клиентов", со стоимостью запроса в 18.10 чего-то (это не время выполнения, а наверное какой-то внутренний показатель скорости или сложности запроса). Так же, кол-во строк которое было обработано (или предполагалось к обработке) и средняя длина строки в байтах. А так же фильтр, по которому фильтруются строки. 

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

#### Ответ

Сначала сделал копии базы и ролей:
```shell
mkdir /tmp/backup
pg_dumpall -cU postgres --roles-only > /tmp/backup/pg_backup-roles.sql
pg_dump -cU postgres -d test_db -F t > /tmp/backup/pg_backup-test_db.tar
```

Далее запускаю вторую ноду:
```shell
docker run --name postgres2 -e POSTGRES_PASSWORD=qqqqqq -d \
-p 5432:5432 \
-v /.docker-data/postgres2/data:/var/lib/postgresql/data \
-v /.docker-data/postgres/backup:/tmp/backup \
postgres:12.17
```

И восстанавливаем данные в новой ноде, сначало роли, потом базу:

```shell
psql -U postgres -f /tmp/backup/pg_backup-roles.sql
pg_restore -cU postgres -d test_db -F t /tmp/backup/pg_backup-test_db.tar
```

P.S. Все команды из заданий выполнял внутри контейнера, в который вхожу вот так:
```shell
docker exec -it postgres /bin/bash
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
