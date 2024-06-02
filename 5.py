r"""
1)	Парсер
a.	Настроить ежедневную инкрементную выгрузку из источника (PostgreSQL) 
    и разложение в реляционную структуру БД только свежих записей.
b.	Составить реляционную структуру БД в виде DDL (SQL, YML или XML). Можно прислать проект.
c.	Запуск максимально простой: в проекте нужны скрипты python 
    и requirements.txt, проект должен запускаться по инструкции в readme для девопса.

NOTE: Инкрементальная загрузка свежих записей реализована посредством выборки данных sql запросом записей 
    за последний день по полю created_at и вставкой данных в соответствующие таблицы

    P.S. так и не понял как сделать ежедневную загрузку без дополнительных планировщиков 
        по типу airflow или встроенных cron выражений
    P.S.S инкрементальная загрузка может затрагивать некоторые данные, которые (возможно) не должны меняться
        например, продукты. (можно добавить обновление записей через upsert)

TODO:
    1. Возможное добавление UPSERT
    2. Перемещение конфигов в отдельный файл
"""

import datetime
import logging
import psycopg2
import os

DB_CONFIG = {
    'dbname': os.environ.get("DB_NAME", "test"),
    'host': os.environ.get("HOST", "localhost"),
    'port': os.environ.get("PORT", "5432"),
    'user': os.environ.get("USER", "postgres"),
    'password': os.environ.get("PASSWORD", "asdhfgjk23821")
}

SQL_PATH = "./5.sql"


# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)


def execute_query(query):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(query)
                result = cur.fetchall()
                return result
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(f"Error executing query: {error}")


def insert_data(data):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        client_id = data['client_id']
        cur.execute("INSERT INTO client (id, name) VALUES (%s, %s) ON CONFLICT (id) DO NOTHING", 
                    (client_id, 'Client Name'))

        for phone in data['phones']:
            for phone_type, number in phone.items():
                cur.execute("INSERT INTO phone (client_id, number, type) VALUES (%s, %s, %s)",
                            (client_id, number, phone_type))

        for address in data['addresses']:
            if address['address']:
                cur.execute(
                    """INSERT INTO address (client_id, date, type, city, street, house, flat) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s)""",
                    (client_id, address['date'], address['type'], address['address']['city'], 
                        address['address']['street'], address['address']['house'], address['address']['flat'])
                )

        for product_name, product_cost in data['products']['product_cost'].items():
            cur.execute("INSERT INTO product (name, cost) VALUES (%s, %s) ON CONFLICT (name) DO NOTHING", 
                        (product_name, product_cost))

        application_id = data['application_id']
        total_sum = data['products']['total_sum']
        order_date = datetime.datetime.now().date()
        cur.execute("INSERT INTO application (id, client_id, order_date, total_sum) VALUES (%s, %s, %s, %s) ON CONFLICT (id) DO NOTHING",
                    (application_id, client_id, order_date, total_sum))

        for product_name, product_cnt in data['products']['product_cnt'].items():
            cur.execute(
                """INSERT INTO application_products (application_id, product, product_cnt) 
                VALUES (%s, %s, %s)""",
                (application_id, product_name, product_cnt)
            )
        conn.commit()
        cur.close()
        logging.info(f"Data for application_id {application_id} inserted successfully.")
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(f"Error inserting data: {error}")
    finally:
        if conn is not None:
            conn.close()


def read_sql_data():
    try:
        with open(SQL_PATH, 'r', encoding='utf-8') as sql_file:
            sql = sql_file.read()
        result = execute_query(sql)
        if result:
            # Extract data from the 'answer' column
            data = [el[1] for el in result]
            return data
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(f"Error reading SQL data: {error}")


def main():
    data_list = read_sql_data()
    if not data_list:
        logging.error(f"No data from sql query")
        return
    for data in data_list:
        insert_data(data)


if __name__ == '__main__':
    main()
