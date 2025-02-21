CREATE TABLE IF NOT EXISTS fact_body_weight (
    weight_key SERIAL PRIMARY KEY,
    date_key INTEGER REFERENCES dim_date(date_key),
    source_key INTEGER REFERENCES dim_measurement_source(source_key),
    weight_value DECIMAL(5,2) NOT NULL,
    measurement_time TIME NOT NULL,
    CONSTRAINT fk_date
        FOREIGN KEY(date_key)
        REFERENCES dim_date(date_key),
    CONSTRAINT fk_source
        FOREIGN KEY(source_key)
        REFERENCES dim_measurement_source(source_key)
);