# SQL_bike_store

# **Documentação do Projeto: Análise de Vendas de Bicicletas**

- **Autor:** Arthur R Neri
- **Data de Criação:** 09 de setembro de 2025

## **1. Visão Geral**

Este documento detalha o processo de configuração do ambiente de banco de dados para a análise de dados de vendas da `bike_store`. O objetivo é garantir um processo de setup padronizado, reproduzível e claro para todos os envolvidos no projeto.

- Fonte de dados: https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database

## **2. Setup do Ambiente de Banco de Dados**

O processo consiste em três etapas principais: criação da database, definição do schema (tabelas e relacionamentos) e a carga dos dados a partir de fontes CSV.

### **2.1. Pré-requisitos**

- **SGBD:** PostgreSQL
- **Cliente SQL:** pgAdmin 4

### **2.2. Criação do Banco de Dados**

Um banco de dados dedicado foi criado para isolar o ambiente de análise.

- **Nome da Database:** `bike_store`
- **Comando SQL: `CREATE DATABASE bike_store;`**

### **2.3. Criação do Schema (Tabelas)**

As tabelas, seus respectivos campos, tipos de dados, chaves primárias e relacionamentos (chaves estrangeiras) foram criados executando o script SQL abaixo. O script está envolto em uma transação (`BEGIN/COMMIT`) para garantir que todas as tabelas sejam criadas com sucesso ou nenhuma seja criada em caso de erro.

```sql
BEGIN;

-- Tabelas independentes primeiro
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

-- Tabelas com dependências
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
    FOREIGN KEY (staff_id) REFERENCES staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
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
```

### **2.4. Carga de Dados (Importação)**

Os dados foram populados nas tabelas a partir de 9 arquivos CSV.

- **Fonte dos Dados:**
    - `brands.csv`
    - `categories.csv`
    - `customers.csv`
    - `order_items.csv`
    - `orders.csv`
    - `products.csv`
    - `staffs.csv`
    - `stocks.csv`
    - `stores.csv`
- **Método de Importação:** A ferramenta **"Import/Export"** do pgAdmin foi utilizada para cada tabela.
- **Configurações Cruciais:**
    - **`Format`**: `csv`
    - **`Header`**: `ON` (Ativado para ignorar a primeira linha do arquivo).
    - **`Delimiter`**: `,` (vírgula).
- **Ordem de Importação:** A importação seguiu uma ordem específica para respeitar as restrições de chave estrangeira:
    1. Tabelas independentes: `brands`, `categories`, `stores`, `customers`.
    2. Tabelas com dependências primárias: `staffs`, `products`.
    3. Tabelas de junção e transações: `stocks`, `orders`.
    4. Tabela de detalhe da transação: `order_items`.

## **3. Verificação**

Após a importação, a contagem de linhas de tabelas chave pode ser verificada para garantir que a carga foi bem-sucedida. Execute as seguintes consultas:

```sql
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
```

## **4. Dicionário de Dados**

Este dicionário descreve a estrutura e o conteúdo de cada tabela no banco de dados `bike_store`.

![inbox_4146319_c5838eb006bab3938ad94de02f58c6c1_SQL-Server-Sample-Database.png](inbox_4146319_c5838eb006bab3938ad94de02f58c6c1_SQL-Server-Sample-Database.png)

---

### 4.1. Tabela `brands`

Armazena as marcas das bicicletas e produtos.

| Nome da Coluna | Tipo de Dado | Chave | Descrição |
| --- | --- | --- | --- |
| `brand_id` | `INT` | PK | Identificador único para cada marca. |
| `brand_name` | `VARCHAR(255)` |  | Nome da marca (ex: 'Electra', 'Haro'). |

---

### 4.2. Tabela `categories`

Armazena as categorias dos produtos.

| Nome da Coluna | Tipo de Dado | Chave | Descrição |
| --- | --- | --- | --- |
| `category_id` | `INT` | PK | Identificador único para cada categoria. |
| `category_name` | `VARCHAR(255)` |  | Nome da categoria (ex: 'Children Bicycles'). |

---

### 4.3. Tabela `products`

Armazena a lista de todos os produtos vendidos.

| Nome da Coluna | Tipo de Dado | Chave | Descrição |
| --- | --- | --- | --- |
| `product_id` | `INT` | PK | Identificador único para cada produto. |
| `product_name` | `VARCHAR(255)` |  | Nome completo do produto (ex: 'Trek 820 - 2016'). |
| `brand_id` | `INT` | FK | Chave estrangeira que referencia `brands(brand_id)`. |
| `category_id` | `INT` | FK | Chave estrangeira que referencia `categories(category_id)`. |
| `model_year` | `SMALLINT` |  | Ano do modelo do produto. |
| `list_price` | `DECIMAL(10,2)` |  | Preço de tabela do produto. |

---

### 4.4. Tabela `stores`

Armazena as informações das lojas físicas.

| Nome da Coluna | Tipo de Dado | Chave | Descrição |
| --- | --- | --- | --- |
| `store_id` | `INT` | PK | Identificador único para cada loja. |
| `store_name` | `VARCHAR(255)` |  | Nome da loja (ex: 'Santa Cruz Bikes'). |
| `phone` | `VARCHAR(25)` |  | Número de telefone de contato da loja. |
| `email` | `VARCHAR(255)` |  | Endereço de e-mail de contato da loja. |
| `street` | `VARCHAR(255)` |  | Endereço da loja (rua e número). |
| `city` | `VARCHAR(255)` |  | Cidade onde a loja está localizada. |
| `state` | `VARCHAR(10)` |  | Sigla do estado (ex: 'CA', 'NY'). |
| `zip_code` | `VARCHAR(10)` |  | Código postal da loja. |

---

### 4.5. Tabela `staffs`

Armazena os dados dos funcionários de cada loja.

| Nome da Coluna | Tipo de Dado | Chave | Descrição |
| --- | --- | --- | --- |
| `staff_id` | `INT` | PK | Identificador único para cada funcionário. |
| `first_name` | `VARCHAR(255)` |  | Primeiro nome do funcionário. |
| `last_name` | `VARCHAR(255)` |  | Sobrenome do funcionário. |
| `email` | `VARCHAR(255)` |  | E-mail corporativo do funcionário. |
| `phone` | `VARCHAR(25)` |  | Telefone de contato do funcionário. |
| `active` | `SMALLINT` |  | Status do funcionário (1 = Ativo, 0 = Inativo). |
| `store_id` | `INT` | FK | Chave estrangeira que referencia `stores(store_id)`. |
| `manager_id` | `INT` | FK | Chave estrangeira que referencia o gerente do funcionário na mesma tabela (`staffs(staff_id)`). |

---

### 4.6. Tabela `stocks`

Armazena a quantidade de cada produto em estoque por loja.

| Nome da Coluna | Tipo de Dado | Chave | Descrição |
| --- | --- | --- | --- |
| `store_id` | `INT` | PK, FK | Parte da chave primária composta; referencia `stores(store_id)`. |
| `product_id` | `INT` | PK, FK | Parte da chave primária composta; referencia `products(product_id)`. |
| `quantity` | `INT` |  | Quantidade do produto em estoque na loja. |

---

### 4.7. Tabela `customers`

Armazena os dados dos clientes.

| Nome da Coluna | Tipo de Dado | Chave | Descrição |
| --- | --- | --- | --- |
| `customer_id` | `INT` | PK | Identificador único para cada cliente. |
| `first_name` | `VARCHAR(255)` |  | Primeiro nome do cliente. |
| `last_name` | `VARCHAR(255)` |  | Sobrenome do cliente. |
| `phone` | `VARCHAR(25)` |  | Telefone de contato do cliente. |
| `email` | `VARCHAR(255)` |  | Endereço de e-mail do cliente. |
| `street` | `VARCHAR(255)` |  | Endereço do cliente (rua e número). |
| `city` | `VARCHAR(255)` |  | Cidade onde o cliente reside. |
| `state` | `VARCHAR(10)` |  | Sigla do estado (ex: 'CA', 'NY'). |

---

### 4.8. Tabela `orders`

Armazena os cabeçalhos dos pedidos de venda.

| Nome da Coluna | Tipo de Dado | Chave | Descrição |
| --- | --- | --- | --- |
| `order_id` | `INT` | PK | Identificador único para cada pedido. |
| `customer_id` | `INT` | FK | Chave estrangeira que referencia `customers(customer_id)`. |
| `order_status` | `SMALLINT` |  | **1 Pendente** (Pending), **2 Processando** (Processing), **3 Enviado** (Shipped) e **4 Concluído** (Completed) |
| `order_date` | `DATE` |  | Data em que o pedido foi realizado. |
| `required_date` | `DATE` |  | Data de entrega solicitada pelo cliente. |
| `shipped_date` | `DATE` |  | Data em que o pedido foi enviado (pode ser nulo). |
| `store_id` | `INT` | FK | Loja onde o pedido foi realizado; referencia `stores(store_id)`. |
| `staff_id` | `INT` | FK | Funcionário que processou o pedido; referencia `staffs(staff_id)`. |

---

### 4.9. Tabela `order_items`

Armazena os itens individuais de cada pedido.

| Nome da Coluna | Tipo de Dado | Chave | Descrição |
| --- | --- | --- | --- |
| `order_id` | `INT` | PK, FK | Parte da chave primária composta; referencia `orders(order_id)`. |
| `item_id` | `INT` | PK | Parte da chave primária composta; identificador sequencial do item dentro do pedido. |
| `product_id` | `INT` | FK | Produto vendido; referencia `products(product_id)`. |
| `quantity` | `INT` |  | Quantidade do produto vendida neste item. |
| `list_price` | `DECIMAL(10,2)` |  | Preço de tabela unitário do produto no momento da venda. |
| `discount` | `DECIMAL(4,2)` |  | Desconto aplicado ao produto (em formato decimal, ex: 0.2 para 20%). |

# Análise Exploratória de Dados (EDA) via SQL

### **1. Qual é o período coberto pelos nossos dados de pedidos?**

```sql
SELECT
    MIN(order_date) AS primeira_data_pedido,
    MAX(order_date) AS ultima_data_pedido
FROM orders;
```

- Tabela:

| primeira_data_pedido | ultima_data_pedido |
| --- | --- |
| 01/01/2016 | 28/12/2018 |

### 2. De quais estados são a maioria dos nossos clientes?

```sql
SELECT
    state,
    COUNT(customer_id) AS total_clientes
FROM customers
GROUP BY state
ORDER BY total_clientes DESC;
```

- Tabela:

| state | total_clientes |
| --- | --- |
| NY | 1019 |
| CA | 284 |
| TX | 142 |

### 3. Quantos produtos temos de cada marca?

```sql
SELECT
    b.brand_name,
    COUNT(p.product_id) AS total_produtos
FROM products AS p
JOIN brands AS b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY total_produtos DESC;
```

- Tabela:

| brand_name | total_produtos |
| --- | --- |
| Trek | 135 |
| Electra | 118 |
| Surly | 25 |
| Sun Bicycles | 23 |
| Haro | 10 |
| Pure Cycles | 3 |
| Heller | 3 |
| Strider | 3 |
| Ritchey | 1 |

### **4. Como está a distribuição de pedidos por loja?**

```sql
-- Análise 4 Corrigida (PostgreSQL)
SELECT
    s.store_name,
    COUNT(o.order_id) AS total_pedidos
FROM orders AS o
JOIN stores AS s ON o.store_id = s.store_id
WHERE o.order_status IN (3, 4) -- Adicionando o filtro de vendas reais
GROUP BY s.store_name
ORDER BY total_pedidos DESC;
```

- Tabela:

| first_name | last_name | order_id | order_date | order_status |
| --- | --- | --- | --- | --- |
| Debra | Burks | 599 | 09/12/2016 | 4 |
| Debra | Burks | 1555 | 18/04/2018 | 1 |
| Debra | Burks | 1613 | 18/11/2018 | 3 |
| Lyndsey | Bean | 1059 | 14/08/2017 | 4 |
| Lyndsey | Bean | 1592 | 27/04/2018 | 2 |
| Lyndsey | Bean | 1611 | 06/09/2018 | 3 |
| Pamelia | Newman | 825 | 07/04/2017 | 4 |
| Pamelia | Newman | 1541 | 16/04/2018 | 2 |
| Pamelia | Newman | 1609 | 23/08/2018 | 3 |
| Emmitt | Sanchez | 352 | 03/08/2016 | 4 |
| Emmitt | Sanchez | 1020 | 23/07/2017 | 3 |
| Emmitt | Sanchez | 1510 | 09/04/2018 | 2 |
| Elinore | Aguilar | 391 | 23/08/2016 | 3 |
| Elinore | Aguilar | 556 | 13/11/2016 | 4 |
| Elinore | Aguilar | 1515 | 10/04/2018 | 1 |
| Melanie | Hayes | 937 | 11/06/2017 | 4 |
| Melanie | Hayes | 1552 | 17/04/2018 | 1 |
| Abby | Gamble | 1318 | 27/12/2017 | 4 |
| Abby | Gamble | 1506 | 08/04/2018 | 1 |
| Corrina | Sawyer | 934 | 09/06/2017 | 4 |
| Corrina | Sawyer | 1578 | 23/04/2018 | 2 |
| Sharyn | Hopkins | 6 | 04/01/2016 | 4 |
| Sharyn | Hopkins | 1482 | 01/04/2018 | 1 |
| Shena | Carter | 1364 | 25/01/2018 | 4 |

### 5. Quais são os nossos produtos mais vendidos?

```sql
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
LIMIT 10;SELECT
    p.product_name,
    SUM(oi.quantity) AS quantidade_total_vendida
FROM order_items AS oi
JOIN products AS p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY quantidade_total_vendida DESC
LIMIT 10;
```

- Tabel

| product_name | quantidade_total_vendida |
| --- | --- |
| Electra Cruiser 1 (24-Inch) - 2016 | 296 |
| Electra Townie Original 7D EQ - 2016 | 288 |
| Electra Townie Original 21D - 2016 | 282 |
| Electra Girl's Hawaii 1 (16-inch) - 2015/2016 | 266 |
| Surly Ice Cream Truck Frameset - 2016 | 165 |
| Electra Girl's Hawaii 1 (20-inch) - 2015/2016 | 152 |
| Trek Slash 8 27.5 - 2016 | 152 |
| Surly Straggler 650b - 2016 | 149 |
| Electra Townie Original 7D - 2015/2016 | 147 |
| Surly Straggler - 2016 | 146 |

### 6. Nossos Clientes Mais Valiosos

```sql
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
  
```

- Tabela:

| first_name | last_name | city | state | valor_total_gasto |
| --- | --- | --- | --- | --- |
| Melanie | Hayes | Liverpool | NY | 270507182 |
| Shena | Carter | Howard Beach | NY | 248906244 |
| Abram | Copeland | Harlingen | TX | 246070261 |
| Brigid | Sharp | Santa Clara | CA | 206489537 |
| Augustina | Joyner | Mount Vernon | NY | 205094254 |
| Cindi | Larson | Howard Beach | NY | 201777457 |
| Tameka | Fisher | Redondo Beach | CA | 197810910 |
| Adena | Blake | Ballston Spa | NY | 193299492 |
| Bess | Mcbride | Garden City | NY | 188533544 |
| Penny | Acevedo | Ballston Spa | NY | 186709288 |

### 7. Receita por Marca

```sql
-- Análise 7: Receita total e percentual por marca (FORMATO BRASILEIRO - CORRIGIDO)
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
-- Etapa 2: Formata os resultados para o padrão brasileiro
SELECT
    brand_name,
    -- CORREÇÃO APLICADA AQUI: Sintaxe de REPLACE aninhado corrigida
    'R$ ' || REPLACE(REPLACE(REPLACE(TO_CHAR(receita_total_bruta, 'FM999,999,990.00'), ',', '#'), '.', ','), '#', '.') AS receita_total_formatada,
    
    -- Formata o percentual para o padrão 12,34 %
    REPLACE(CAST(ROUND((receita_total_bruta / SUM(receita_total_bruta) OVER ()) * 100, 2) AS TEXT), '.', ',') || ' %' AS percentual_da_receita_total
FROM ReceitaPorMarca
ORDER BY receita_total_bruta DESC; -- A ordenação ainda usa o valor numérico bruto
```

- Tabela:

| brand_name | receita_total_formatada | percentual_da_receita_total |
| --- | --- | --- |
| Trek | $ 4.602.754,35 | 59,86% |
| Electra | $ 1.205.320,82 | 15,68% |
| Surly | $ 949.507,06 | 12,35% |
| Sun Bicycles | $ 341.994,93 | 4,45% |
| Haro | $ 185.384,55 | 2,41% |
| Heller | $ 171.459,08 | 2,23% |
| Pure Cycles | $ 149.476,34 | 1,94% |
| Ritchey | $ 78.898,95 | 1,03% |
| Strider | $ 4.320,48 | 0,06% |

### 8. Desempenho das Marcas por Loja

```sql
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
```

- Tabela:

| store_name | brand_name | receita_loja_marca |
| --- | --- | --- |
| Baldwin Bikes | Trek | $                  3,124,284.78 |
| Baldwin Bikes | Electra | $                       808,762.05 |
| Baldwin Bikes | Surly | $                       637,447.37 |
| Baldwin Bikes | Sun Bicycles | $                       233,742.44 |
| Baldwin Bikes | Haro | $                       129,689.72 |
| Baldwin Bikes | Heller | $                       120,801.83 |
| Baldwin Bikes | Pure Cycles | $                       105,683.72 |
| Baldwin Bikes | Ritchey | $                          52,469.30 |
| Baldwin Bikes | Strider | $                             2,870.07 |
| Rowlett Bikes | Trek | $                       552,655.05 |
| Rowlett Bikes | Electra | $                       118,523.01 |
| Rowlett Bikes | Surly | $                          90,432.21 |
| Rowlett Bikes | Sun Bicycles | $                          46,943.69 |
| Rowlett Bikes | Haro | $                          19,444.81 |
| Rowlett Bikes | Pure Cycles | $                          18,915.06 |
| Rowlett Bikes | Heller | $                          16,552.00 |
| Rowlett Bikes | Ritchey | $                             3,494.95 |
| Rowlett Bikes | Strider | $                                 581.46 |
| Santa Cruz Bikes | Trek | $                       925,814.53 |
| Santa Cruz Bikes | Electra | $                       278,035.76 |
| Santa Cruz Bikes | Surly | $                       221,627.48 |
| Santa Cruz Bikes | Sun Bicycles | $                          61,308.79 |
| Santa Cruz Bikes | Haro | $                          36,250.02 |
| Santa Cruz Bikes | Heller | $                          34,105.24 |
| Santa Cruz Bikes | Pure Cycles | $                          24,877.56 |
| Santa Cruz Bikes | Ritchey | $                          22,934.69 |
| Santa Cruz Bikes | Strider | $                                 868.96 |

### 9. Receita Total por Ano

```sql
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
```

- Tabela:

| ano | receita_total_anual |
| --- | --- |
| 2016 | $                                       2,427,378.53 |
| 2017 | $                                       3,447,208.24 |
| 2018 | $                                           996,607.93 |

### 10. Preferências dos Clientes "VIP”

```sql
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
```

- Tabelas:

| brand_name | product_name | unidades_compradas_pelos_vips |
| --- | --- | --- |
| Trek | Trek Silque SLR 7 Women's - 2017 | 5 |
| Trek | Trek Silque SLR 8 Women's - 2017 | 4 |
| Trek | Trek Madone 9.2 - 2017 | 5 |
| Trek | Trek Domane SLR 9 Disc - 2018 | 2 |
| Trek | Trek Remedy 9.8 - 2017 | 4 |
| Trek | Trek Powerfly 7 FS - 2018 | 3 |
| Trek | Trek Domane SLR 6 Disc - 2017 | 2 |
| Trek | Trek Super Commuter+ 8S - 2018 | 2 |
| Surly | Surly Karate Monkey 27.5+ Frameset - 2017 | 4 |
| Trek | Trek Emonda SLR 6 - 2018 | 2 |
| Trek | Trek Domane SL 6 - 2017 | 2 |
| Trek | Trek Domane SL 8 Disc - 2018 | 1 |
| Trek | Trek Fuel EX 8 29 - 2016 | 2 |
| Trek | Trek Domane S 6 - 2017 | 2 |
| Trek | Trek Fuel EX 5 Plus - 2018 | 2 |

### 11. Receita Mensal ao Longo do Tempo

```sql
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
```

- Tabela:

| ano | mes_numero | receita_mensal |
| --- | --- | --- |
| 2016 | 1 | $             215,146.42 |
| 2016 | 2 | $             156,112.32 |
| 2016 | 3 | $             180,600.33 |
| 2016 | 4 | $             167,144.05 |
| 2016 | 5 | $             205,270.01 |
| 2016 | 6 | $             210,562.12 |
| 2016 | 7 | $             199,556.81 |
| 2016 | 8 | $             225,657.38 |
| 2016 | 9 | $             273,091.61 |
| 2016 | 10 | $             212,078.08 |
| 2016 | 11 | $             182,329.41 |
| 2016 | 12 | $             199,829.98 |
| 2017 | 1 | $             285,616.48 |
| 2017 | 2 | $             312,923.75 |
| 2017 | 3 | $             308,911.90 |
| 2017 | 4 | $             227,290.91 |
| 2017 | 5 | $             268,233.24 |
| 2017 | 6 | $             378,865.65 |
| 2017 | 7 | $             229,995.40 |
| 2017 | 8 | $             290,553.46 |
| 2017 | 9 | $             293,405.26 |
| 2017 | 10 | $             310,328.31 |
| 2017 | 11 | $             281,577.90 |
| 2017 | 12 | $             259,505.98 |
| 2018 | 1 | $             381,430.10 |
| 2018 | 2 | $             200,658.06 |
| 2018 | 3 | $             363,990.99 |
| 2018 | 6 | $                        188.99 |
| 2018 | 7 | $                11,337.90 |
| 2018 | 8 | $                   8,377.81 |
| 2018 | 9 | $                   8,963.96 |
| 2018 | 10 | $                   3,781.13 |
| 2018 | 11 | $                11,362.01 |
| 2018 | 12 | $                   6,516.97 |

# Conclusões & Insights

### **Visão Geral**

A análise dos dados de vendas de 2016 a 2018 revela um negócio com um modelo de sucesso claro, mas altamente concentrado em um único mercado. A empresa demonstrou um crescimento robusto e impressionante de 2016 para 2017, impulsionado por uma loja principal e uma estratégia de marcas bem definida, visando dois segmentos de clientes distintos. O insight mais crítico, no entanto, é uma **queda drástica e real no desempenho de vendas a partir do segundo trimestre de 2018**, que reverteu a trajetória de crescimento e se tornou o principal ponto de atenção para a saúde do negócio.

### **Principais Descobertas e Insights Chave**

### **1. Saúde do Negócio: Crescimento Robusto Seguido por um Colapso em 2018**

- **Crescimento Comprovado:** A empresa apresentou um crescimento de receita de **42%** de 2016 (**$2.42M**) para 2017 (**$3.44M**), indicando uma operação saudável e em plena expansão.
- **O Colapso de 2018:** A receita em 2018 despencou para **$996k**. A análise mensal revelou que isso se deve a uma **queda catastrófica nas vendas a partir de abril de 2018**, e não a uma falha na coleta de dados.
- **Performance Real de 2018:** O primeiro trimestre de 2018 foi o mais forte da história da empresa. No entanto, o desempenho subsequente indica um grave problema de mercado ou operacional que precisa ser investigado com urgência.

### **2. O Motor de Nova York: Um Negócio Hiperlocalizado**

- **Dominância Geográfica:** A operação é massivamente centrada no estado de Nova York. A loja **Baldwin Bikes (NY)** é a força motriz indiscutível do negócio, responsável pela grande maioria dos pedidos e da receita.
- **Base de Clientes Concentrada:** O perfil dos clientes reflete o desempenho das lojas. A maioria dos clientes, incluindo a maior parte dos clientes de alto valor, reside em Nova York.
- **Modelo Consistente:** O sucesso das marcas principais, especialmente da Trek, é replicado em todas as lojas (NY, CA, TX), mas em escalas muito diferentes, indicando um modelo de negócio consistente.

### **3. A Estratégia Dupla de Marcas: Trek (Valor) vs. Electra (Volume)**

- **Trek - A Campeã de Valor:** Responsável por quase **60% de toda a receita**, a Trek é o pilar financeiro da empresa. Seus produtos, de maior valor agregado, são os que garantem a lucratividade.
- **Electra - A Campeã de Volume:** Embora contribua com uma fatia menor da receita (~16%), a Electra domina a lista de produtos mais vendidos em *unidades*. Suas bicicletas de passeio (Cruiser, Townie) servem como porta de entrada para um público mais casual e garantem o giro de estoque.
- **Conclusão Estratégica:** A empresa opera com sucesso uma estratégia de duas frentes: atrai um grande volume de clientes com a Electra e maximiza a receita e a lealdade com os produtos de alta performance da Trek.

### **4. O Perfil do Cliente VIP: Leal, Local e Focado em Performance**

- **Comportamento de Compra:** Nossos clientes mais valiosos são quase que exclusivamente compradores de produtos de alta performance. A lista de seus produtos favoritos é dominada por bicicletas da marca **Trek**. A marca de volume, Electra, não tem relevância para este segmento.
- **Perfil:** O cliente ideal é leal (fazendo múltiplas compras), reside em Nova York e busca produtos de alto desempenho, demonstrando ser um ciclista entusiasta e não casual.

### **Recomendações Estratégicas e Próximos Passos**

1. **Prioridade Máxima - Investigar a Causa da Queda de 2018:** A ação mais urgente é formar uma força-tarefa para entender o que causou o colapso nas vendas a partir de abril de 2018. A investigação deve cobrir fatores internos (mudanças de preço, problemas de estoque, equipe) e externos (entrada de novos concorrentes, crise econômica local, etc.).
2. **Dobrar a Aposta em Nova York:** Dada a performance estelar e a resiliência da Baldwin Bikes, todos os esforços de marketing, programas de fidelidade e gerenciamento de estoque devem ser focados em fortalecer ainda mais este mercado.
3. **Marketing Segmentado:** Criar campanhas de marketing distintas: uma para aquisição de novos clientes, focada nos modelos mais acessíveis da Electra, e outra para retenção e upsell, focada nos entusiastas da Trek, promovendo os lançamentos de alta performance.
4. **Desenvolver o Cliente VIP:** Criar um programa de relacionamento para os clientes de maior valor, oferecendo benefícios exclusivos, acesso antecipado a produtos Trek e eventos, fortalecendo a lealdade desse grupo crucial para o negócio.

# **Documentação do Dashboard: Arquitetura BigQuery & Looker Studio**

- **Autor:** Arthur R. Neri
- **Data de Criação:** 11 de setembro de 2025
- **Versão:** 2.0 (Arquitetura em Nuvem)
- Link para Dashboard: https://lookerstudio.google.com/reporting/a98da5a8-e0b3-45cb-88c3-ccf14a495793

### **1. Visão Geral da Arquitetura**

Para superar os desafios de conexão de um banco de dados local com uma ferramenta de BI na nuvem, o projeto foi migrado para uma arquitetura 100% Google Cloud. Os dados brutos (CSVs) foram carregados no Google BigQuery, que serve como o Data Warehouse central. O Looker Studio se conecta diretamente ao BigQuery para consumir os dados e gerar as visualizações.

### **2. Configuração do Ambiente Google Cloud / BigQuery**

As seguintes etapas foram necessárias para preparar o ambiente:

1. **Criação do Projeto Google Cloud:** Um novo projeto foi criado com as seguintes especificações:
    - **Nome do Projeto:** `bike-store`
    - **ID do Projeto:** `bike-store-471719`
2. **Criação do Conjunto de Dados no BigQuery:** Dentro do projeto, um conjunto de dados foi criado para conter todas as tabelas.
    - **ID do Conjunto de Dados:** `bike_store`
3. **Ativação de APIs Essenciais:** Para permitir a comunicação entre o Looker Studio e o BigQuery, as seguintes APIs foram ativadas no projeto:
    - `BigQuery API`
    - `BigQuery Connection API`
    - `Cloud Resource Manager API`
4. **Vinculação da Conta de Faturamento:** O projeto foi vinculado a uma conta de faturamento ativa para permitir a execução de queries no BigQuery. O uso para este projeto se enquadra no nível gratuito do serviço.

### **3. Processo de Carga de Dados (Importação para o BigQuery)**

Os 9 datasets originais em formato CSV foram carregados diretamente na interface do BigQuery.

- **Método:** Para cada uma das 9 tabelas, o seguinte processo foi utilizado:
    1. Dentro do conjunto de dados `bike_store`, a opção **"CRIAR TABELA"** foi selecionada.
    2. **Origem:** A opção **"Upload"** foi usada para carregar o arquivo CSV do computador local.
    3. **Nome da Tabela:** O nome da tabela foi definido para corresponder ao arquivo (ex: `orders`, `products`).
    4. **Esquema (Schema):** A opção **"Detecção automática"** foi utilizada para que o BigQuery definisse os tipos de dados de cada coluna.
    5. **Cabeçalho:** Nas "Opções Avançadas", o campo **"Linhas de cabeçalho a serem ignoradas"** foi configurado como `1`.

### **4. Ponto Crítico: Dialeto SQL (Legacy vs. Standard)**

Durante a fase de testes, foi descoberto que o ambiente BigQuery do projeto, por padrão, estava operando com o dialeto **Legacy SQL**. Funções modernas do Standard SQL (como `FORMAT_NUMERIC`) não funcionaram. Embora a partir da análise 6, conseguirmos utilizar o modelo Standard 

- **Decisão:** Para garantir a consistência, foi decidido prosseguir utilizando a sintaxe **Legacy SQL no primeiro momento, porém alternamos para o modelo Standard a partir da análise 6 pois o Legacy apresentou bugs**. A sintaxe do Legacy SQL se diferencia principalmente na forma de referenciar as tabelas.
- **Sintaxe (Legacy SQL):** `[ID_do_Projeto:ID_do_Conjunto_de_Dados.Nome_da_Tabela]`
    - **Exemplo Prático:** `[bike-store-471719:bike_store.orders]`

### **5. Conexão e Configuração do Looker Studio**

A conexão final do dashboard foi estabelecida com as seguintes preferências:

- **Conector:** `BigQuery`.
- **Método de Consulta:** Todas as fontes de dados para gráficos e KPIs foram criadas usando a opção **"CONSULTA PERSONALIZADA"**, onde os scripts SQL (em dialeto Legacy) são inseridos.
- **Regra de Ouro da Formatação:** Para máxima flexibilidade e performance, foi estabelecido o seguinte padrão:
    1. A query SQL deve retornar os valores numéricos **brutos**, sem formatação de texto (sem `R$`, `%` ou vírgulas decimais).
    2. Toda a formatação visual (moeda, porcentagem, casas decimais) é aplicada diretamente no Looker Studio, na aba de **"CONFIGURAÇÃO"** da métrica ou na aba de **"ESTILO"** do gráfico.
- Exemplo de Query Padrão (Legacy SQL - Sem Formatação):

```sql
-- Template de query para Looker Studio
SELECT
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS Receita_Total
FROM
  [bike-store-471719:bike_store.orders] AS o
JOIN
  [bike-store-471719:bike_store.order_items] AS oi ON o.order_id = oi.order_id
WHERE o.order_status IN (3, 4);
```

# Documentação de queries para Looker

### **1. KPI - Receita Total**

- **Objetivo:** Calcular o valor total em dólar de todas as vendas enviadas ou concluídas.
- **Tipo de Visualização:** Cartão de pontuação.
- **Query para BigQuery (Legacy SQL):**

```sql
-- Retorna o valor bruto da receita
SELECT
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS Receita_Total
FROM
  [bike-store-471719:bike_store.orders] AS o
JOIN
  [bike-store-471719:bike_store.order_items] AS oi ON o.order_id = oi.order_id
WHERE o.order_status IN (3, 4);
```

### **2. KPI - Total de Pedidos**

- **Objetivo:** Contar o número total de vendas enviadas ou concluídas.
- **Tipo de Visualização:** Cartão de pontuação.
- **Query para BigQuery (Legacy SQL):**

```sql
-- Retorna o número total de pedidos válidos
SELECT
  COUNT(o.order_id) AS Total_Pedidos
FROM
  [bike-store-471719:bike_store.orders] AS o
WHERE o.order_status IN (3, 4);
```

### **3. KPI - Clientes Únicos**

- **Objetivo:** Contar quantos clientes distintos fizeram pelo menos uma compra válida.
- **Tipo de Visualização:** Cartão de pontuação.
- **Query para BigQuery (Legacy SQL):**

```sql
-- Retorna o número de clientes únicos com pedidos válidos
SELECT
  COUNT(DISTINCT o.customer_id) AS Clientes_Unicos
FROM
  [bike-store-471719:bike_store.orders] AS o
WHERE o.order_status IN (3, 4);
```

### **4. KPI - Ticket Médio**

- **Objetivo:** Calcular o valor médio de cada transação (Receita Total / Total de Pedidos).
- **Tipo de Visualização:** Cartão de pontuação.
- **Query para BigQuery (Legacy SQL):**

```sql
-- Análise 4: KPI - Ticket Médio (CORRIGIDO PARA LEGACY SQL)
SELECT
  -- Usamos CASE WHEN para evitar divisão por zero
  CASE
    WHEN COUNT(o.order_id) > 0
    THEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) / COUNT(o.order_id)
    ELSE 0
  END AS Ticket_Medio
FROM
  [bike-store-471719:bike_store.orders] AS o
JOIN
  [bike-store-471719:bike_store.order_items] AS oi ON o.order_id = oi.order_id
WHERE o.order_status IN (3, 4);
```

### **5. KPI - Receita Média por Cliente**

- **Objetivo:** Calcular o valor médio que cada cliente único gerou em receita (Receita Total / Clientes Únicos).
- **Tipo de Visualização:** Cartão de pontuação.
- **Query para BigQuery (Legacy SQL):**

```sql
-- Análise 5: KPI - Receita Média por Cliente (CORRIGIDO PARA LEGACY SQL)
SELECT
  -- Usamos CASE WHEN para evitar divisão por zero
  CASE
    WHEN COUNT(DISTINCT o.customer_id) > 0
    THEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) / COUNT(DISTINCT o.customer_id)
    ELSE 0
  END AS Receita_Media_Por_Cliente
FROM
  [bike-store-471719:bike_store.orders] AS o
JOIN
  [bike-store-471719:bike_store.order_items] AS oi ON o.order_id = oi.order_id
WHERE o.order_status IN (3, 4);
```

### **6. Receita por Marca**

- **Objetivo:** Visualizar a contribuição de receita de cada marca, identificando as mais importantes financeiramente para o negócio.
- **Tipo de Visualização:** **Gráfico de Barras Verticais**.
- Query para BigQuery (Standard SQL): Aqui precisamos voltar para o modo Standard pois o Legacy mode não estava funcionando conforme o esperado

```sql
#standardSQL
-- Versão final e definitiva em Standard SQL
SELECT
  b.brand_name,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_total
FROM
  `bike-store-471719.bike_store.brands` AS b
JOIN
  `bike-store-471719.bike_store.products` AS p ON b.brand_id = p.brand_id
JOIN
  `bike-store-471719.bike_store.order_items` AS oi ON p.product_id = oi.product_id
JOIN
  `bike-store-471719.bike_store.orders` AS o ON oi.order_id = o.order_id
WHERE o.order_status IN (3, 4)
GROUP BY
  b.brand_name
ORDER BY
  receita_total DESC;
```

### 7. Receita por Loja

- **Objetivo:** Visualizar o desempenho financeiro de cada loja para entender a distribuição geográfica da receita e identificar a loja de maior faturamento.
- **Tipo de Visualização:** Gráfico de Barras
- Query para BigQuery (Standard SQL):

```sql
#standardSQL
-- Retorna a receita bruta total para cada loja, ordenada da maior para a menor
SELECT
  s.store_name,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_total
FROM
  `bike-store-471719.bike_store.stores` AS s
JOIN
  `bike-store-471719.bike_store.orders` AS o ON s.store_id = o.store_id
JOIN
  `bike-store-471719.bike_store.order_items` AS oi ON o.order_id = oi.order_id
WHERE o.order_status IN (3, 4)
GROUP BY
  s.store_name
ORDER BY
  receita_total DESC;
```

### **8. Evolução da Receita por Ano**

- **Objetivo:** Visualizar a tendência de crescimento da receita da empresa ano a ano.
- **Tipo de Visualização:** **Gráfico de Linhas**
- **Query para BigQuery (Standard SQL):**

```sql
#standardSQL
-- Retorna a receita bruta total para cada ano
SELECT
  EXTRACT(YEAR FROM o.order_date) AS ano,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_total
FROM
  `bike-store-471719.bike_store.orders` AS o
JOIN
  `bike-store-471719.bike_store.order_items` AS oi ON o.order_id = oi.order_id
WHERE o.order_status IN (3, 4)
GROUP BY
  ano
ORDER BY
  ano;
```

### 9. Top Produtos Trek em NY

- **Objetivo:** Identificar os produtos específicos da marca Trek que geram mais receita na loja de maior desempenho (Baldwin Bikes).
- **Tipo de Visualização:** **Gráfico de Barras Horizontais**
- **Query para BigQuery (Standard SQL):**

```sql
#standardSQL
-- Retorna os 10 produtos Trek mais vendidos por receita na loja Baldwin Bikes
SELECT
  p.product_name,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_total
FROM
  `bike-store-471719.bike_store.stores` AS s
JOIN
  `bike-store-471719.bike_store.orders` AS o ON s.store_id = o.store_id
JOIN
  `bike-store-471719.bike_store.order_items` AS oi ON o.order_id = oi.order_id
JOIN
  `bike-store-471719.bike_store.products` AS p ON oi.product_id = p.product_id
JOIN
  `bike-store-471719.bike_store.brands` AS b ON p.brand_id = b.brand_id
WHERE
  o.order_status IN (3, 4)
  AND s.store_name = 'Baldwin Bikes' -- Filtro pela loja
  AND b.brand_name = 'Trek'          -- Filtro pela marca
GROUP BY
  p.product_name
ORDER BY
  receita_total DESC
LIMIT 10; -- Pegamos os 10 principais
```

### **10. Análise de Descontos por Produto**

- **Objetivo:** Identificar os produtos que recebem a maior média de desconto, para analisar a estratégia de precificação e o possível impacto na margem de lucro.
- **Tipo de Visualização:** **Tabela**. Uma tabela é a melhor visualização aqui porque queremos ver várias informações lado a lado para cada produto (desconto, unidades vendidas, receita) e poder ordená-las de diferentes maneiras.
- **Query para BigQuery (Standard SQL):**

```sql
#standardSQL
-- Retorna os 15 produtos com a maior média de desconto aplicado
SELECT
  p.product_name,
  AVG(oi.discount) AS media_desconto,
  SUM(oi.quantity) AS unidades_vendidas,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_total
FROM
  `bike-store-471719.bike_store.products` AS p
JOIN
  `bike-store-471719.bike_store.order_items` AS oi ON p.product_id = oi.product_id
JOIN
  `bike-store-471719.bike_store.orders` AS o ON oi.order_id = o.order_id
WHERE
  o.order_status IN (3, 4)
  AND oi.discount > 0 -- Focamos apenas nos itens que tiveram algum desconto
GROUP BY
  p.product_name
ORDER BY
  media_desconto DESC
LIMIT 15;
```

### **11. Receita Mensal ao Longo do Tempo**

- **Objetivo:** Visualizar a tendência da receita mês a mês ao longo de todo o período, para identificar padrões de sazonalidade (meses de alta e baixa) e a trajetória de crescimento.
- **Tipo de Visualização:** **Gráfico de Séries Temporais (Time series chart)**.
- **Query para BigQuery (Standard SQL):**

```sql
#standardSQL
-- Retorna a receita total para cada mês/ano
SELECT
  -- Esta função agrupa todos os dias de um mês no primeiro dia daquele mês.
  -- Ex: '2017-08-25' se torna '2017-08-01'. Isso cria um campo de data perfeito para o gráfico.
  DATE_TRUNC(o.order_date, MONTH) AS mes_ano,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_mensal
FROM
  `bike-store-471719.bike_store.orders` AS o
JOIN
  `bike-store-471719.bike_store.order_items` AS oi ON o.order_id = oi.order_id
WHERE o.order_status IN (3, 4)
GROUP BY
  mes_ano
ORDER BY
  mes_ano;
```

### 12. Frequência de Compra dos Clientes

- **Objetivo:** Entender a distribuição da base de clientes de acordo com o número de pedidos que eles fizeram. Isso nos ajuda a visualizar a proporção de clientes novos vs. clientes leais.
- **Tipo de Visualização:** **Gráfico de Barras Verticais**. Ideal para mostrar a contagem de clientes para cada "faixa" de frequência (clientes com 1 pedido, 2 pedidos, etc.).
- **Query para BigQuery (Standard SQL):**

```sql
#standardSQL
-- Retorna a contagem de clientes para cada frequência de compra
WITH FrequenciaClientes AS (
  -- Primeiro, contamos quantos pedidos cada cliente fez
  SELECT
    customer_id,
    COUNT(order_id) AS numero_de_pedidos
  FROM
    `bike-store-471719.bike_store.orders`
  WHERE
    order_status IN (3, 4)
  GROUP BY
    customer_id
)
-- Agora, contamos quantos clientes existem para cada número de pedidos
SELECT
  numero_de_pedidos,
  COUNT(customer_id) AS numero_de_clientes
FROM
  FrequenciaClientes
GROUP BY
  numero_de_pedidos
ORDER BY
  numero_de_pedidos;
```

### **13. Recalculando os Clientes VIP (A Versão da Verdade)**

Para solidificar essa descoberta e termos a lista correta dos nossos melhores clientes (mesmo que eles tenham comprado poucas vezes), vamos refazer a análise de "Clientes Mais Valiosos" com a nossa lógica correta no BigQuery.

- **Objetivo:** Gerar a lista definitiva dos 10 clientes mais valiosos com base em vendas reais (`status 3 ou 4`).
- **Tipo de Visualização:** **Tabela**.
- **Query para BigQuery (Standard SQL):**

```sql
#standardSQL
-- Retorna os 10 clientes mais valiosos com base em vendas reais
SELECT
  c.first_name,
  c.last_name,
  c.city,
  c.state,
  COUNT(o.order_id) AS total_pedidos_validos,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS valor_total_gasto
FROM
  `bike-store-471719.bike_store.customers` AS c
JOIN
  `bike-store-471719.bike_store.orders` AS o ON c.customer_id = o.customer_id
JOIN
  `bike-store-471719.bike_store.order_items` AS oi ON o.order_id = oi.order_id
WHERE o.order_status IN (3, 4)
GROUP BY
  c.customer_id, c.first_name, c.last_name, c.city, c.state
ORDER BY
  valor_total_gasto DESC
LIMIT 10;
```

### **14. Comparativo Mensal de Vendas (Trek vs. Electra) em 2017 vs. 2018**

- **Objetivo:** Comparar o desempenho de vendas mensais das duas marcas principais (Trek e Electra) durante o ano de pico (2017) e o ano do colapso (2018). Isso nos permitirá ver se a queda foi generalizada ou se afetou uma marca mais do que a outra.
- **Tipo de Visualização:** **Gráfico de Combinação (Combo chart)** ou **Gráfico de Linhas com múltiplas séries**. Esta é a melhor forma de comparar diferentes categorias (as marcas) ao longo do tempo.
- **Query para BigQuery (Standard SQL):**

```sql
#standardSQL
-- Retorna a receita mensal para as marcas Trek e Electra nos anos de 2017 e 2018
SELECT
  DATE_TRUNC(o.order_date, MONTH) AS mes_ano,
  b.brand_name,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS receita_mensal
FROM
  `bike-store-471719.bike_store.orders` AS o
JOIN
  `bike-store-471719.bike_store.order_items` AS oi ON o.order_id = oi.order_id
JOIN
  `bike-store-471719.bike_store.products` AS p ON oi.product_id = p.product_id
JOIN
  `bike-store-471719.bike_store.brands` AS b ON p.brand_id = b.brand_id
WHERE
  o.order_status IN (3, 4)
  AND EXTRACT(YEAR FROM o.order_date) IN (2017, 2018) -- Filtro para os dois anos chave
  AND b.brand_name IN ('Trek', 'Electra')             -- Filtro para as duas marcas chave
GROUP BY
  mes_ano,
  brand_name
ORDER BY
  mes_ano,
  brand_name;
```

### LINK PARA O DASHBOARD: https://lookerstudio.google.com/reporting/a98da5a8-e0b3-45cb-88c3-ccf14a495793

### **Conclusão Final Sobre a Crise de 2018**

A crise de 2018 não foi uma queda geral de mercado ou um problema com todas as lojas. Foi um evento muito específico: por algum motivo, a empresa **parou de vender produtos da Trek**. As hipóteses para isso seriam:

- Uma ruptura no fornecimento com a Trek.
- A perda da licença de revendedor da marca.
- Uma decisão estratégica desastrosa de parar de vender a marca mais lucrativa.
- Um problema de dados específico que parou de registrar as vendas da Trek.