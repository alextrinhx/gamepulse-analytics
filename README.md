# GamePulse Analytics

## Overview

GamePulse Analytics is an end-to-end gaming content analytics project that originated from my experience working in content at Overtime Gaming.

The project began as a way to explore how gaming content data could be used to identify high-growth games, creators, and content opportunities. After my internship, I independently expanded the project into a complete data analytics and engineering portfolio project to apply and demonstrate skills across data ingestion, cloud storage, data warehousing, transformation, analytics, and business intelligence.

GamePulse was initially developed using Python, PostgreSQL, SQL, and Power BI, then expanded into a cloud analytics pipeline using AWS S3, Snowflake, and dbt.

## Tech Stack

- **Python** — API ingestion, data processing, and pipeline development
- **YouTube Data API** — Public gaming video and creator data
- **PostgreSQL** — Initial relational analytics database
- **AWS S3** — Cloud storage for raw data
- **Snowflake** — Cloud data warehouse
- **dbt** — Data transformation, modeling, and testing
- **SQL** — Analytics logic and data modeling
- **Power BI** — Interactive analytics dashboard and reporting

## Architecture

```text
YouTube Data API
       |
       v
Python Data Pipeline
       |
       v
    AWS S3
       |
       v
Snowflake RAW Layer
       |
       v
 dbt Transformations
       |
       v
Snowflake Analytics Layer
       |
       v
    Power BI
```

The project evolved from an initial PostgreSQL-based implementation into a cloud analytics architecture. PostgreSQL was used to prototype and validate the original analytics logic before the pipeline was migrated to AWS S3, Snowflake, and dbt.

## Data Pipeline

### 1. Data Ingestion

Python scripts collect public gaming content and creator data through the YouTube Data API. The ingestion process captures metrics such as video views, engagement, channel information, and game associations.

### 2. Cloud Storage

Raw pipeline outputs are stored in AWS S3, providing a cloud-based raw data layer separate from the analytics warehouse.

### 3. Snowflake Warehouse

Data from S3 is loaded into Snowflake and organized into raw, staging, and analytics layers.

The warehouse contains transformed datasets for:

- Game performance
- Game opportunity analysis
- Creator performance
- Creator intelligence
- Platform summaries
- Dashboard KPIs

### 4. dbt Transformations

dbt manages the transformation layer between raw Snowflake data and analytics-ready models.

The dbt project includes:

- Staging models for cleaning and standardizing source data
- Intermediate analytics logic
- Mart models for games, creators, and dashboard reporting
- Data-quality tests defined in YAML
- Reusable transformations with model dependencies managed through `ref()`

Running `dbt build` creates the analytics models and validates the configured data-quality tests.

### 5. Power BI

The final Snowflake analytics models feed an interactive Power BI dashboard that summarizes gaming content performance and surfaces potential opportunities.

The dashboard includes:

- Games tracked
- Creators tracked
- Content analyzed
- Total views tracked
- Average engagement
- Game opportunity rankings
- Creator opportunity rankings
- Recommendation categories

## Analytics Logic

### Game Opportunity Score

GamePulse evaluates games using audience and engagement signals to identify potential content opportunities.

The resulting score is used to categorize games into recommendations such as:

- **Increase Coverage**
- **Watch Closely**
- **Monitor**

This provides a simplified decision-support layer rather than relying only on raw engagement and audience metrics.

### Creator Intelligence

Creator analytics combine channel-level information with observed content performance.

The creator model considers metrics such as:

- Subscriber count
- Average views
- Engagement rate
- View efficiency
- Content volume
- Confidence score

A confidence component helps reduce the influence of creators represented by very small content samples. The final creator impact score is used to rank potential creators for further evaluation.

Creator analysis focuses on established channels with at least 10,000 subscribers to reduce noise from extremely small accounts and produce more meaningful comparisons.

## Project Evolution

GamePulse was developed iteratively in two main stages:

**Initial Analytics Prototype**

```text
YouTube API → Python → PostgreSQL → SQL Views → Power BI
```

This version established the ingestion process, analytics logic, scoring methodology, and dashboard.

**Cloud Analytics Pipeline**

```text
YouTube API → Python → AWS S3 → Snowflake → dbt → Power BI
```

The second version migrated the analytics workflow to a cloud-based architecture. Raw data is stored in S3, Snowflake provides the warehouse layer, and dbt manages transformations and analytics models.

This migration preserved the original business logic while separating ingestion, storage, transformation, and visualization into distinct layers.

## Key Takeaways

GamePulse demonstrates an end-to-end analytics workflow covering data ingestion, cloud storage, data warehousing, transformation, data quality, analytics modeling, and business intelligence.

The project also demonstrates the migration of an analytics workflow from a local PostgreSQL implementation to a modern cloud data stack using AWS S3, Snowflake, and dbt.