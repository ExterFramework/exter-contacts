CREATE TABLE IF NOT EXISTS reputation (
    citizen_id VARCHAR(50) NOT NULL,
    domain VARCHAR(50) NOT NULL,
    reputation FLOAT NOT NULL DEFAULT 0,
    PRIMARY KEY (citizen_id, domain)
);