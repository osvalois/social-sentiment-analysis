import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import from_utc_timestamp, date_format

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read data from DynamoDB
dynamodb_table = glueContext.create_dynamic_frame.from_catalog(
    database="social_sentiment_db",
    table_name="raw_tweets"
)

# Apply transformations
mapped_dyf = ApplyMapping.apply(frame = dynamodb_table, mappings = [
    ("id", "string", "tweet_id", "string"),
    ("text", "string", "tweet_text", "string"),
    ("created_at", "string", "created_at", "timestamp"),
    ("sentiment", "string", "sentiment", "string"),
    ("retweet_count", "long", "retweet_count", "long"),
    ("reply_count", "long", "reply_count", "long"),
    ("like_count", "long", "like_count", "long"),
    ("quote_count", "long", "quote_count", "long")
])

# Convert DynamicFrame to DataFrame for more complex transformations
df = mapped_dyf.toDF()

# Add date and hour columns
df = df.withColumn("date", date_format(from_utc_timestamp(df["created_at"], "UTC"), "yyyy-MM-dd"))
df = df.withColumn("hour", date_format(from_utc_timestamp(df["created_at"], "UTC"), "HH"))

# Convert back to DynamicFrame
processed_dyf = DynamicFrame.fromDF(df, glueContext, "processed_dyf")

# Write to S3 in Parquet format
glueContext.write_dynamic_frame.from_options(
    frame = processed_dyf,
    connection_type = "s3",
    connection_options = {"path": "s3://your-bucket-name/processed_tweets/"},
    format = "parquet"
)

job.commit()