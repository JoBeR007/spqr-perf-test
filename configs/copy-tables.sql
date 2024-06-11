DROP TABLE IF EXISTS history_orig CASCADE;
DROP TABLE IF EXISTS new_order_orig CASCADE;
DROP TABLE IF EXISTS order_line_orig CASCADE;
DROP TABLE IF EXISTS oorder_orig CASCADE;
DROP TABLE IF EXISTS customer_orig CASCADE;
DROP TABLE IF EXISTS district_orig CASCADE;
DROP TABLE IF EXISTS stock_orig CASCADE;
DROP TABLE IF EXISTS item_orig CASCADE;
DROP TABLE IF EXISTS warehouse_orig CASCADE;

CREATE TABLE item
AS TABLE item_orig;

CREATE TABLE warehouse
AS TABLE warehouse_orig;

CREATE TABLE stock
AS TABLE stock_orig;

CREATE TABLE district
AS TABLE district_orig;

CREATE TABLE customer
AS TABLE customer_orig;

CREATE INDEX idx_customer_name ON customer (C_W_ID, C_D_ID, C_LAST, C_FIRST);

CREATE TABLE history
AS TABLE history_orig;

CREATE TABLE oorder
AS TABLE oorder_orig;

CREATE TABLE new_order
AS TABLE new_order_orig;

CREATE TABLE order_line
AS TABLE order_line_orig;