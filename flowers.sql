CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) NOT NULL, 
    email VARCHAR(100)
);

CREATE TABLE salespersons (
    seat_number SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    salesperson_seat INT REFERENCES salespersons(seat_number),
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL
);

CREATE TABLE order_details (
    detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);


-- Функция для форматирования номера телефона
CREATE OR REPLACE FUNCTION format_phone_number() RETURNS TRIGGER AS $$
BEGIN
    -- Удалим все лишние символы, оставим только цифры
    NEW.phone_number := regexp_replace(NEW.phone_number, '[^0-9]', '', 'g');
    
    -- Если номер начинается с 9 (например, 9123456789), добавим +7
    IF LENGTH(NEW.phone_number) = 10 AND LEFT(NEW.phone_number, 1) = '9' THEN
        NEW.phone_number := '+7' || NEW.phone_number;
    -- Если номер начинается с 8, заменим его на +7
    ELSIF LENGTH(NEW.phone_number) = 11 AND LEFT(NEW.phone_number, 1) = '8' THEN
        NEW.phone_number := '+7' || RIGHT(NEW.phone_number, 10);
    -- Если номер начинается с 7, добавим "+"
    ELSIF LENGTH(NEW.phone_number) = 11 AND LEFT(NEW.phone_number, 1) = '7' THEN
        NEW.phone_number := '+7' || RIGHT(NEW.phone_number, 10);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для применения функции при вставке или обновлении данных
CREATE TRIGGER phone_number_format_trigger
BEFORE INSERT OR UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION format_phone_number();



-- Вставка клиента с разными форматами номера телефона
INSERT INTO customers (first_name, last_name, phone_number, email)
VALUES ('Ivan', 'Ivanov', '8 (912) 345-67-89', 'ivanov@example.com');

INSERT INTO customers (first_name, last_name, phone_number, email)
VALUES ('Olga', 'Petrova', '+7 999 123 45 67', 'petrova@example.com');

INSERT INTO customers (first_name, last_name, phone_number, email)
VALUES ('Petr', 'Sidorov', '9123456789', 'sidorov@example.com');
