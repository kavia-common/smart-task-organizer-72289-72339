# Todo Database (MySQL helper)

This folder contains helper scripts to provision and start a local MySQL database suitable for the Todo backend.

Key scripts:
- startup.sh: Initializes and starts MySQL (if not already running), creates database/user, applies schema.sql, and writes connection info.
- backup_db.sh / restore_db.sh: Utility scripts for backing up and restoring.

Outputs:
- db_connection.txt: A ready-to-copy mysql CLI command for connection.
- db_visualizer/mysql.env: Convenience exports for DB viewer tooling.

Defaults used by scripts:
- DB_NAME=myapp
- DB_USER=appuser
- DB_PASSWORD=dbuser123
- DB_PORT=5000

Use these values in the backend .env or compose them into MYSQL_URL:
- mysql+pymysql://appuser:dbuser123@localhost:5000/myapp

Startup order (recommended):
1) Database (this folder): ./startup.sh
2) Backend (Flask): configure .env using above values, then run python run.py
3) Frontend (React): set REACT_APP_API_BASE=http://localhost:5000, then npm start
