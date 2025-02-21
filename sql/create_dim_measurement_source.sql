/*
    A dimension table for measurement sources.

    This table will hold dimensional data about sources for:
    - body weight
*/
CREATE TABLE IF NOT EXISTS dim_measurement_source (
    source_key SERIAL PRIMARY KEY,
    source_name VARCHAR(50) NOT NULL,
    device_model VARCHAR(100),
    is_current BOOLEAN NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE
);