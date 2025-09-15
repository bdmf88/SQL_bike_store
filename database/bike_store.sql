BEGIN;

CREATE TABLE brands (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL,
    phone VARCHAR(25),
    email VARCHAR(255),
    street VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(10),
    zip_code VARCHAR(10)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    phone VARCHAR(25),
    email VARCHAR(255) NOT NULL UNIQUE,
    street VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(10),
    zip_code VARCHAR(10)
);

CREATE TABLE staffs (
    staff_id INT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(25),
    active SMALLINT NOT NULL,
    store_id INT NOT NULL,
    manager_id INT,
    FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES staffs (staff_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year SMALLINT NOT NULL,
    list_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES brands (brand_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE stocks (
    store_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_status SMALLINT NOT NULL,
    order_date DATE NOT NULL,
    required_date DATE NOT NULL,
    shipped_date DATE,
    store_id INT NOT NULL,
    staff_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staffs (staff_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE order_items (
    order_id INT,
    item_id INT,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    list_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(4, 2) NOT NULL,
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMIT;

--- VERIFICAÇÃO ---

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;

--- INICIO DE EDA ---
--- 1. Qual é o período coberto pelos nossos dados de pedidos? ---

SELECT
    MIN(order_date) AS primeira_data_pedido,
    MAX(order_date) AS ultima_data_pedido
FROM orders;

--- 2. De quais estados são a maioria dos nossos clientes? ---

SELECT
    state,
    COUNT(customer_id) AS total_clientes
FROM customers
GROUP BY state
ORDER BY total_clientes DESC;

--- 3. Quantos produtos temos de cada marca? --- 

SELECT
    b.brand_name,
    COUNT(p.product_id) AS total_produtos
FROM products AS p
JOIN brands AS b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY total_produtos DESC;

--- 4. Como está a distribuição de pedidos por loja? ---

-- Análise 4 Corrigida (PostgreSQL)
SELECT
    s.store_name,
    COUNT(o.order_id) AS total_pedidos
FROM orders AS o
JOIN stores AS s ON o.store_id = s.store_id
WHERE o.order_status IN (3, 4) -- Adicionando o filtro de vendas reais
GROUP BY s.store_name
ORDER BY total_pedidos DESC;

--- 5. Quais são os nossos produtos mais vendidos? ---

-- Análise 5 Corrigida (PostgreSQL)
SELECT
    p.product_name,
    SUM(oi.quantity) AS quantidade_total_vendida
FROM order_items AS oi
JOIN products AS p ON oi.product_id = p.product_id
JOIN orders AS o ON oi.order_id = o.order_id -- Join adicionado para acessar o status
WHERE o.order_status IN (3, 4) -- Filtro de vendas reais adicionado
GROUP BY p.product_name
ORDER BY quantidade_total_vendida DESC
LIMIT 10;

--- 6. Nossos Clientes Mais Valiosos ---

-- Análise 6 Corrigida (PostgreSQL)
SELECT
    c.first_name,
    c.last_name,
    c.city,
    c.state,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS valor_total_gasto
FROM
    customers AS c
JOIN
    orders AS o ON c.customer_id = o.customer_id
JOIN
    order_items AS oi ON o.order_id = oi.order_id
WHERE
    o.order_status IN (3, 4) -- CORREÇÃO DO FILTRO
GROUP BY
    c.customer_id -- Agrupamos pelo ID para garantir a unicidade do cliente
ORDER BY
    valor_total_gasto DESC
LIMIT 10;

--- 7: Receita por Marca ---

-- Análise 7: Receita total e percentual por marca (DÓLAR + FORMATO BR)
WITH ReceitaPorMarca AS (
    -- Etapa 1: Calcula a receita bruta para cada marca
    SELECT
        b.brand_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_total_bruta
    FROM order_items AS oi
    JOIN products AS p ON oi.product_id = p.product_id
    JOIN brands AS b ON p.brand_id = b.brand_id
    GROUP BY b.brand_name
)
-- Etapa 2: Formata os resultados para o padrão desejado
SELECT
    brand_name,
    -- AQUI: Símbolo da moeda alterado para Dólar
    '$ ' || REPLACE(REPLACE(REPLACE(TO_CHAR(receita_total_bruta, 'FM999,999,990.00'), ',', '#'), '.', ','), '#', '.') AS receita_total_formatada,
    
    -- Formata o percentual para o padrão 12,34 %
    REPLACE(CAST(ROUND((receita_total_bruta / SUM(receita_total_bruta) OVER ()) * 100, 2) AS TEXT), '.', ',') || ' %' AS percentual_da_receita_total
FROM ReceitaPorMarca
ORDER BY receita_total_bruta DESC; -- A ordenação ainda usa o valor numérico bruto



--- 8: Desempenho das Marcas por Loja ---
-- Análise 8: Receita por Marca em Cada Loja (FORMATO BR SEM SÍMBOLO)
SELECT
    s.store_name,
    b.brand_name,
    -- AQUI: Símbolo '$ ' removido da formatação
    REPLACE(REPLACE(REPLACE(TO_CHAR(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 'FM999,999,990.00'), ',', '#'), '.', ','), '#', '.') AS receita_loja_marca
FROM orders AS o
JOIN stores AS s ON o.store_id = s.store_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
JOIN brands AS b ON p.brand_id = b.brand_id
GROUP BY s.store_name, b.brand_name
ORDER BY s.store_name, SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC;

--- 9. A Evolução do Negócio ao Longo do Tempo ---
-- Análise 9 Corrigida (PostgreSQL)
SELECT
    EXTRACT(YEAR FROM o.order_date) AS ano,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_total_anual
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
WHERE
    o.order_status IN (3, 4) -- CORREÇÃO DO FILTRO
GROUP BY
    ano
ORDER BY
    ano;

--- 10. Preferências dos Clientes "VIP" ---

-- Análise 10 Corrigida (PostgreSQL)
WITH Top10Clientes AS (
    SELECT
        o.customer_id
    FROM
        orders AS o
    JOIN
        order_items AS oi ON o.order_id = oi.order_id
    WHERE
        o.order_status IN (3, 4) -- CORREÇÃO DO FILTRO
    GROUP BY
        o.customer_id
    ORDER BY
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
    LIMIT 10
)
SELECT
    b.brand_name,
    p.product_name,
    SUM(oi.quantity) AS unidades_compradas_pelos_vips
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
JOIN
    brands AS b ON p.brand_id = b.brand_id
JOIN
    Top10Clientes AS vip ON o.customer_id = vip.customer_id
WHERE
    o.order_status IN (3, 4) -- CORREÇÃO DO FILTRO
GROUP BY
    b.brand_name,
    p.product_name
ORDER BY
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
LIMIT 15;


--- 11: Investigando a Queda de 2018 ---
-- Análise 11 Corrigida (PostgreSQL)
SELECT
    EXTRACT(YEAR FROM o.order_date) AS ano,
    EXTRACT(MONTH FROM o.order_date) AS mes_numero,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_mensal
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
WHERE
    o.order_status IN (3, 4) -- CORREÇÃO DO FILTRO
GROUP BY
    ano,
    mes_numero
ORDER BY
    ano,
    mes_numero;








