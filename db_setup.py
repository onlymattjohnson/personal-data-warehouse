import os
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

def create_database():
    """Create the database and user if they don't exist."""
    # Connect to default database to create new DB
    conn = psycopg2.connect(
        dbname=os.getenv("DEFAULT_DB_NAME"),
        user=os.getenv("DEFAULT_DB_USER"),
        password=os.getenv("DEFAULT_DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT")
    )
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    
    # Create database if it doesn't exist
    db_name = os.getenv("DB_NAME")
    cur.execute(f"SELECT 1 FROM pg_database WHERE datname = '{db_name}'")
    if not cur.fetchone():
        cur.execute(f"CREATE DATABASE {db_name}")
    
    # Create user if doesn't exist
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")
    cur.execute(f"SELECT 1 FROM pg_roles WHERE rolname = '{db_user}'")
    if not cur.fetchone():
        cur.execute(f"CREATE USER {db_user} WITH PASSWORD '{db_password}'")
        cur.execute(f"GRANT ALL PRIVILEGES ON DATABASE {db_name} TO {db_user}")
    
    cur.close()
    conn.close()

def execute_sql_file(cursor, file_path):
    """Execute SQL commands from a file."""
    with open(file_path, 'r') as file:
        sql_commands = file.read()
    cursor.execute(sql_commands)

def create_tables():
    """Create the raw and dimensional tables."""
    conn = psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT")
    )
    cur = conn.cursor()

    # Execute SQL files
    sql_dir = os.path.join(os.path.dirname(__file__), 'sql')
    execute_sql_file(cur, os.path.join(sql_dir, 'create_raw_body_weight.sql'))
    execute_sql_file(cur, os.path.join(sql_dir, 'create_dim_date.sql'))
    execute_sql_file(cur, os.path.join(sql_dir, 'create_dim_measurement_source.sql'))
    execute_sql_file(cur, os.path.join(sql_dir, 'create_fact_body_weight.sql'))

    conn.commit()
    cur.close()
    conn.close()

if __name__ == "__main__":
    create_database()
    create_tables()