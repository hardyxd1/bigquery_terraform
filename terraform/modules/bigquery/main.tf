locals {
  config = jsondecode(file(var.config_file))
}

# Create or update datasets based on configuration
resource "google_bigquery_dataset" "datasets" {
  for_each = {
    for scenario in local.config.scenarios : scenario.dataset_id => scenario
    if scenario.name == "new_dataset_and_tables"  # Solo crear nuevos datasets
  }

  dataset_id = each.value.dataset_id
  location   = each.value.location
}

# Create or update tables based on configuration
resource "google_bigquery_table" "tables" {
  for_each = merge([
    for scenario in local.config.scenarios : {
      for table in scenario.tables : "${scenario.dataset_id}.${table.name}" => {
        dataset_id = scenario.dataset_id
        table     = table
      }
    }
  ]...)

  dataset_id = each.value.dataset_id
  table_id   = each.value.table.name

  schema = jsonencode([
    for field in each.value.table.schema.fields : {
      name = field.name
      type = field.type
      mode = field.mode
    }
  ])

  depends_on = [google_bigquery_dataset.datasets]
}

# Output for import commands
output "import_commands" {
  value = {
    for scenario in local.config.scenarios : scenario.dataset_id => {
      for table in scenario.tables : table.name => "terraform import 'google_bigquery_table.tables[\"${scenario.dataset_id}.${table.name}\"]' '${var.project_id}.${scenario.dataset_id}.${table.name}'"
    }
    if scenario.name == "existing_dataset_new_table"
  }
}

# Load data into tables if data files exist
resource "null_resource" "load_data" {
  for_each = merge([
    for scenario in local.config.scenarios : {
      for table in scenario.tables : "${scenario.dataset_id}.${table.name}" => {
        dataset_id = scenario.dataset_id
        table_name = table.name
        data_file  = "${path.module}/../../../data/dummy_data/${table.name}.json"
      }
      if fileexists("${path.module}/../../../data/dummy_data/${table.name}.json")
    }
  ]...)

  provisioner "local-exec" {
    command = <<-EOT
      bq load --source_format=NEWLINE_DELIMITED_JSON \
      ${var.project_id}:${each.value.dataset_id}.${each.value.table_name} \
      ${each.value.data_file}
    EOT
  }
  depends_on = [google_bigquery_table.tables]
} 