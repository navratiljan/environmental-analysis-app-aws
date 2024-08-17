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
