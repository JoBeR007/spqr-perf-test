DROP DISTRIBUTION ALL CASCADE;
DROP KEY RANGE ALL;

CREATE DISTRIBUTION ds1 COLUMN TYPES integer;

CREATE KEY RANGE krid2 FROM 301 ROUTE TO sh2 FOR DISTRIBUTION ds1;
CREATE KEY RANGE krid1 FROM 1 ROUTE TO sh1 FOR DISTRIBUTION ds1;

ALTER DISTRIBUTION ds1 ATTACH RELATION warehouse DISTRIBUTION KEY W_ID;
ALTER DISTRIBUTION ds1 ATTACH RELATION warehouse DISTRIBUTION KEY w_id;
ALTER DISTRIBUTION ds1 ATTACH RELATION district DISTRIBUTION KEY D_W_ID;
ALTER DISTRIBUTION ds1 ATTACH RELATION stock DISTRIBUTION KEY S_W_ID;
ALTER DISTRIBUTION ds1 ATTACH RELATION customer DISTRIBUTION KEY C_W_ID;
ALTER DISTRIBUTION ds1 ATTACH RELATION history DISTRIBUTION KEY H_W_ID;
ALTER DISTRIBUTION ds1 ATTACH RELATION oorder DISTRIBUTION KEY O_W_ID;
ALTER DISTRIBUTION ds1 ATTACH RELATION order_line DISTRIBUTION KEY OL_W_ID;
ALTER DISTRIBUTION ds1 ATTACH RELATION new_order DISTRIBUTION KEY NO_W_ID;