prefix              = "stg"
resource_group_name = "rg-staging"
location            = "westeurope"

db_admin    = "dbadmin"
db_password = "SuperS3cret!ChangeMe" # temporary for learning; use Key Vault later

# App settings that will be injected into the App Service
database_username = "sqladminuser"
database_password = "ChangeMe123!"

# Allowed client IPs for SQL firewall (example: your dev IP). Can be [] to allow all (not recommended).
allowed_ips = ["0.0.0.0"]
