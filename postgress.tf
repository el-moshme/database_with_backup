provider "ibm" {
  ibmcloud_api_key = "<YOUR IBM CLOUD API KEY>"
  region = "us-south"
}

resource "ibm_resource_instance" "postgres_instance" {
  name = "my-postgres-instance"
  service = "databases-for-postgresql"
  plan = "standard"
  tags = ["postgresql"]
}

resource "ibm_resource_instance" "cos_instance" {
  name = "my-cos-instance"
  service = "cloud-object-storage"
  plan = "standard"
}

resource "ibm_database_connection" "postgres_connection" {
  name = "my-postgres-connection"
  resource_instance_id = ibm_resource_instance.postgres_instance.guid
  service_credentials = jsonencode(ibm_resource_instance.postgres_instance.credentials[0])
  type = "postgresql"
  endpoint = ibm_database_connection.postgres_connection.primary_host
  port = ibm_database_connection.postgres_connection.primary_port
  username = ibm_database_connection.postgres_connection.username
  password = ibm_database_connection.postgres_connection.password
  database = "postgres"
}

resource "ibm_database" "my_database" {
  name = "my_database"
  service_instance_id = ibm_resource_instance.postgres_instance.guid
}

resource "ibm_database_user" "my_user" {
  name = "my_user"
  service_instance_id = ibm_resource_instance.postgres_instance.guid
  password = "<YOUR PASSWORD>"
  email = "<YOUR EMAIL>"
}

resource "ibm_database_privilege" "my_privilege" {
  user_id = ibm_database_user.my_user.id
  database_id = ibm_database.my_database.id
  type = "administrator"
}

resource "ibm_database_schema" "my_schema" {
  name = "my_schema"
  database_id = ibm_database.my_database.id
}

resource "ibm_database_table" "my_table" {
  name = "my_table"
  database_id = ibm_database.my_database.id
  schema_id = ibm_database_schema.my_schema.id
  columns {
    name = "id"
    type = "serial"
  }
  columns {
    name = "name"
    type = "text"
  }
}

resource "ibm_database_sequence" "my_sequence" {
  name = "my_sequence"
  database_id = ibm_database.my_database.id
  schema_id = ibm_database_schema.my_schema.id
  increment = 1
  min_value = 1
  max_value = 1000
}

resource "ibm_cos_bucket" "my_bucket" {
  name = "my-bucket"
  resource_instance_id = ibm_resource_instance.cos_instance.guid
}

resource "ibm_database_backup" "my_backup" {
  name = "my_backup"
  database_id = ibm_database.my_database.id
  cos_bucket_id = ibm_cos_bucket.my_bucket.id
  cron_schedule = "0 0 * * *"
}

variable "postgres_plan" {
  description = "The plan for the PostgreSQL instance"
  default = "standard"
}

variable "cos_plan" {
  description = "The plan for the Cloud Object Storage instance"
  default = "standard"
}

provider "ibm" {
  ibmcloud_api_key = "<YOUR IBM CLOUD API KEY>"
  region = "us-south"
}

resource "ibm_resource_instance" "postgres_instance" {
  name = "my-postgres-instance"
  service = "databases-for-postgresql"
  plan = var.postgres_plan
  tags = ["postgresql"]
}

resource "ibm_resource_instance" "cos_instance" {
  name = "my-cos-instance"
  service = "cloud-object-storage"
  plan = var.cos_plan
}
