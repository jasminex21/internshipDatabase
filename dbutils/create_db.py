import sqlite3
from create_app_dir import create_app_dir
import os

def create_db(username): 
    dir_path = create_app_dir()
    db_path = os.path.join(dir_path, f"{username}.db")
    db_conn = sqlite3.connect(db_path)
    db_cursor = db_conn.cursor()
    # create table to store applications
    create_query = """ 
    CREATE TABLE Applications (
        id INTEGER PRIMARY KEY, 
        cycle TEXT, 
        date TEXT, 
        position TEXT, 
        company TEXT, 
        description TEXT, 
        tags TEXT, 
        status TEXT)"""
    db_cursor.execute(create_query)

    db_conn.commit()
    db_conn.close()

    return db_path