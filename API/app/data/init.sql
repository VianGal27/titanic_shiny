CREATE TABLE titanic (
    id SERIAL PRIMARY KEY,
    survived INT,
    pclass INT,
    name VARCHAR(500),
    sex VARCHAR(20),
    age FLOAT,
    siblings_Spouses_Aboard INT,
    parents_Children_Aboard INT,
    fare FLOAT
);
COPY titanic
FROM '/data/titanic.csv' 
DELIMITER ',' 
CSV HEADER
NULL as 'NA';
