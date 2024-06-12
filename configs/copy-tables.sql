DROP TABLE IF EXISTS history CASCADE;
DROP TABLE IF EXISTS new_order CASCADE;
DROP TABLE IF EXISTS order_line CASCADE;
DROP TABLE IF EXISTS oorder CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS district CASCADE;
DROP TABLE IF EXISTS stock CASCADE;
DROP TABLE IF EXISTS item CASCADE;
DROP TABLE IF EXISTS warehouse CASCADE;

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