## Setup Cheat Sheet

Here’s a quick reference to set up and run the CVE Database Manager:

| **Step** | **Command/Details** |
| --- | --- |
| **Ensure PostgreSQL is installed** | **Install PostgreSQL:**<br>For Debian/Ubuntu:<br>`sudo apt update`<br>`sudo apt install postgresql postgresql-contrib`<br><br>For CentOS/RHEL:<br>`sudo yum install postgresql-server postgresql-contrib`<br>`sudo postgresql-setup initdb`<br>`sudo systemctl start postgresql`<br>`sudo systemctl enable postgresql` |
| **Switch to PostgreSQL User** | `sudo -i -u postgres` |
| **Access PostgreSQL Shell** | `psql` |
| **Create a New User and Database** | `CREATE USER your_username WITH PASSWORD 'your_password';`<br>`CREATE DATABASE your_database;`<br>`GRANT ALL PRIVILEGES ON DATABASE your_database TO your_username;`<br>`\q`<br>`exit` |
| **Clone the Repository** | `git clone https://github.com/iam-niranjan/cve-database-manager.git`<br>`cd cve-database-manager` |
| **Install Dependencies** | `pip install -r requirements.txt` |
| **Clone the CVE Data Repository** | `git clone https://github.com/CVEProject/cvelistV5.git` |
| **Create Database Schema** | Use SQL statements in `db_schema.sql` to create tables and views in PostgreSQL. |
| **Update the Database** | Run `python update_cve_db.py` to populate and update the database with CVE data. |
| **Run the FastAPI Application** | `uvicorn api:app --host 0.0.0.0 --port 8000` |

### Notes

* `update_cve_db.py`: Update placeholders for `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, `CVE_REPO_PATH`. Ensure to add your local path to `CVE_REPO_PATH`.
* `api.py`: Update placeholders for `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_HOST`, `DB_PORT`, and set `VALID_API_KEY` to any randomly generated value for API key security.
