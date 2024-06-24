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

CREATE TABLE history
AS TABLE history_orig;

CREATE TABLE oorder
AS TABLE oorder_orig;

CREATE TABLE new_order
AS TABLE new_order_orig;

CREATE TABLE order_line
AS TABLE order_line_orig;

CREATE INDEX idx_item on item (I_ID);

CREATE INDEX idx_warehouse on warehouse (W_ID);

CREATE INDEX idx_district_name ON district (D_W_ID, D_ID);

CREATE INDEX idx_customer_name ON customer (C_W_ID, C_D_ID, C_LAST, C_FIRST);

CREATE INDEX idx_oorder_name ON oorder (O_W_ID,O_D_ID,O_ID);

CREATE INDEX fkey_stock_2_name ON stock (S_W_ID, S_I_ID);

CREATE INDEX fkey_new_order_1_name ON new_order (NO_W_ID, NO_D_ID);

CREATE INDEX fkey_new_order_2_name ON new_order (NO_W_ID, NO_D_ID, NO_O_ID);

CREATE INDEX fkey_order_line_2_name ON order_line (OL_W_ID, OL_D_ID, OL_O_ID);

CREATE INDEX fkey_history_1_name ON history (H_C_W_ID,H_C_D_ID,H_C_ID);

CREATE INDEX fkey_history_2_name ON history (H_W_ID,H_D_ID);