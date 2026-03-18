
# CVE Database Manager

This repository contains scripts and configurations to manage a CVE database and serve the data via a FastAPI application.

## Introduction

This project leverages data from the [CVEProject/cvelistV5](https://github.com/CVEProject/cvelistV5) repository, the official CVE List, a catalog of all CVE Records identified by or reported to the CVE Program. It provides a local CVE database for internal automation and quick access to CVE data via an API, simplifying integration into various environments, especially beneficial for air-gapped setups.

## Features

- **Local CVE Database**: Bypass the complexities and rate limits of the NVD API.
- **FastAPI Interface**: Access CVE data through an automated Swagger or ReDoc documented API.

## Getting Started

### Prerequisites

- PostgreSQL
- Python 3.x

### Setup

1. **PostgreSQL Installation**: Install PostgreSQL on your Linux system using the distribution's package manager.

    ```bash
    sudo apt update
    sudo apt install postgresql postgresql-contrib
    ```

2. **Switch User**: Switch to the `postgres` user.

    ```bash
    sudo -i -u postgres
    ```

3. **Database Setup**: Create a user, a new database, and assign privileges.

    ```sql
    psql
    CREATE USER your_username WITH PASSWORD 'your_password';
    CREATE DATABASE your_database;
    GRANT ALL PRIVILEGES ON DATABASE your_database TO your_username;
    \q
    exit
    ```

4. **Clone the Repository**:

    ```bash
    git clone https://github.com/iam-niranjan/cve-database-manager.git
    cd cve-database-manager
    ```

5. **Install Dependencies**:

    ```bash
    pip install -r requirements.txt
    ```

6. **Clone the CVE Data Repository**:

    ```bash
    git clone https://github.com/CVEProject/cvelistV5.git
    ```

### Database Schema

- Create tables and views using the SQL script provided in `db_schema.sql`.

### Python Script

- Execute the `update_cve_db.py` script to update the database with the latest CVE data from the local repository.

### Run the Application

- Start the FastAPI server to serve the CVE data via the API.

    ```bash
    uvicorn api:app --host 0.0.0.0 --port 8000
    ```

## Usage

Once the database is populated and the FastAPI server is running, you can access the CVE data through the API endpoints. For example, to retrieve details for a specific CVE:

```bash
curl -H "X-API-Key: <your_api_key>" http://localhost:8000/cve/CVE-2023-0001
```

## Documentation

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

These interfaces provide a comprehensive overview of the API endpoints, allowing direct interaction and exploration of available operations and data structures.
