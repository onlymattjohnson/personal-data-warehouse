CREATE TABLE IF NOT EXISTS metrics.body_weight (
    id bigserial PRIMARY KEY,
    source_name varchar(200),
    weight_in_pounds numeric(5,2) NOT NULL,
    date_logged timestamp with time zone
);