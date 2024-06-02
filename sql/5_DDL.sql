CREATE TABLE client (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL
);

CREATE TABLE phone (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    number VARCHAR NOT NULL,
    type VARCHAR NOT NULL,
    FOREIGN KEY (client_id) REFERENCES client(id)
);

CREATE TABLE address (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    date DATE,
    type VARCHAR NOT NULL,
    city VARCHAR,
    street VARCHAR,
    house VARCHAR,
    flat VARCHAR,
    FOREIGN KEY (client_id) REFERENCES client(id)
);

CREATE TABLE product (
    name VARCHAR PRIMARY KEY,
    cost INT NOT NULL
);

CREATE TABLE application (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_sum INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES client(id)
);

CREATE TABLE application_products (
    id SERIAL PRIMARY KEY,
    application_id INT NOT NULL,
    product VARCHAR NOT NULL,
    product_cnt INT NOT NULL,
    FOREIGN KEY (application_id) REFERENCES application(id),
    FOREIGN KEY (product) REFERENCES product(name)
);
