## Dependencys
- Python 3.8+
- PostgreSQL 12+
- psycopg2 2.9.9
- Pandas 2.2.2 (for task 6)
- SQLAlchemy 2.0.30 (for task 6)

## Setup

### 1. Clone the Repository
```bash
git clone https://github.com/Moroes/direct_credit.git
cd direct_credit
```

### 2. Create and Activate a Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  
```
On Windows use 
```bash
venv\Scripts\activate
```
### 3. Edit .env file

### 4. Create tables from sql file
```bash
psql -U postgres -d postgres -f ./sql/5_DDL.sql
```

### 5. Run python file
```bash
python ./5.py
```

# For task 6
You need to place the test csv in the project root and edit table name in .env or variable TABLE_NAME in 6.py
