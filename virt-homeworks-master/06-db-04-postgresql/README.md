# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

#### Ответ

```shell
docker run  -d \
--name postgres13 \
-e POSTGRES_PASSWORD=qqqqqq \
-p 5432:5432 \
-v /.docker-data/postgres13/data:/var/lib/postgresql/data \
-v /.docker-data/postgres13/backup:/tmp/backup \
postgres:13.13

docker exec -it postgres13 /bin/bash

psql -U postgres
```

```yaml
# вывод списка БД:
\l 
# подключение к БД:
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo} 
# вывод списка таблиц:
\dt[S+] [PATTERN] # или \d[S+]
# вывод описания содержимого таблиц:
\d[S+] NAME 
# выход из psql:
\q
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

#### Ответ

```postgresql
postgres=# CREATE DATABASE test_database;
CREATE DATABASE

postgres=# \c test_database

postgres=# \i /tmp/backup/test_dump.sql
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
```

> Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Анализ по какой таблице? Сделал по `orders`:

```postgresql
test_database=# ANALYZE VERBOSE public.orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE

test_database=# SELECT avg_width FROM pg_stats WHERE tablename = 'orders';
 avg_width 
-----------
         4
         4
        16
(3 rows)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

#### Ответ

SQL-транзакция для шардирования таблицы:

```postgresql
test_database=# 
    BEGIN;
        CREATE TABLE public.orders_part (
            id INTEGER NOT NULL,
            title VARCHAR(80) NOT NULL,
            price INTEGER
        ) PARTITION BY RANGE(price);
        CREATE TABLE public.orders_part_less_499 PARTITION OF public.orders_part FOR VALUES FROM (0) TO (499);
        CREATE TABLE public.orders_part_more_500 PARTITION OF public.orders_part FOR VALUES FROM (499) TO (999999);
        INSERT INTO public.orders_part (id, title, price) SELECT * FROM public.orders;
    COMMIT;
BEGIN
CREATE TABLE
CREATE TABLE
CREATE TABLE
INSERT 0 8
COMMIT
```

> Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

Да, можно было бы. По сути надо было бы сделать то же что и в транзакции выше. Типо такого:

```postgresql
CREATE TABLE public.orders (
    id INTEGER NOT NULL,
    title VARCHAR(80) NOT NULL,
    price INTEGER
) PARTITION BY RANGE(price);
CREATE TABLE public.orders_part_less_499 PARTITION OF public.orders FOR VALUES FROM (0) TO (499);
CREATE TABLE public.orders_part_more_500 PARTITION OF public.orders FOR VALUES FROM (499) TO (999999);
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

#### Ответ

```shell
pg_dump -U postgres -d test_database > /tmp/backup/test_database_dump.sql
```

По уникальности - кроме `unique`, почему-то ничего не приходит в голову :(

Т.е. получается так (взял из `test_dump.sql` и добавил `unique` для `title`):

```postgresql
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
);
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
