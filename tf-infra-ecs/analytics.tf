resource "aws_athena_database" "example" {
  name   = "envstats"
  bucket = "environmental-app-dataset-bucket"
}

resource "aws_kms_key" "example" {
  deletion_window_in_days = 7
  description             = "Athena KMS Key"
}

resource "aws_athena_workgroup" "example" {
  name = "envstats-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://environmental-app-athena-results"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.example.arn
      }
    }
  }
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = "ese-api8"
  database_name = aws_athena_database.example.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location = "s3://environmental-app-dataset-bucket/datasets"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "serialization.format" = ","
        "field.delim" = ","
      }
    }

    columns {
      name = "dt"
      type = "string"
    }

    columns {
      name = "landaveragetemperature"
      type = "double"
    }
    columns {
      name = "landaveragetemperatureuncertainty"
      type = "double"
    }
  }
}


resource "aws_glue_data_quality_ruleset" "example" {
  name    = "glue-data-quality-ruleset"
  ruleset = <<-EOT
    Rules = [
      RowCount between 290328 and 1161312,
      IsComplete "dt",
      ColumnLength "dt" between 1 and 11,
      IsComplete "col3",
      ColumnLength "col3" <= 41,
      ColumnLength "col4" <= 29,
      ColumnLength "col5" <= 21,
      ColumnLength "col6" <= 29,
      ColumnLength "col7" <= 30,
      ColumnLength "col8" <= 41
    ]
  EOT

  target_table {
    database_name = aws_athena_database.example.name
    table_name    = aws_glue_catalog_table.aws_glue_catalog_table.name
  }
}


resource "aws_sqs_queue" "example" {
  name = "envstats-sqs-dlq"
}

resource "aws_scheduler_schedule" "example" {
  name       = "my-schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }


  schedule_expression = "rate(5 minutes)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:glue:StartDataQualityRulesetEvaluationRun"
    role_arn = aws_iam_role.glue_data_quality_role.arn

    dead_letter_config {
      arn = aws_sqs_queue.example.arn
    }

    input = <<EOF
    {
      "DataSource": {
        "GlueTable": {
          "DatabaseName": "envstats",
          "TableName": "ese-api8"
        }
      },
      "Role": "arn:aws:iam::812222239604:role/glue-data-quality-role",
      "RulesetNames": [
        "initial-test"
      ]
    }
    EOF
  }
}