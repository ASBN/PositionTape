.bail on
.read languages/sqlite/src/position_tape.sql

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('length', '0');
SELECT CASE WHEN (SELECT text FROM position_tape_generate) = '' THEN 1 ELSE fail('zero length') END;

UPDATE position_tape_params SET value = '11' WHERE name = 'length';
SELECT CASE WHEN (SELECT text FROM position_tape_generate) = '12345678911' THEN 1 ELSE fail('basic generation') END;

UPDATE position_tape_params SET value = '100' WHERE name = 'length';
SELECT CASE WHEN length((SELECT text FROM position_tape_generate)) = 100 THEN 1 ELSE fail('exact boundary') END;
SELECT CASE WHEN length((SELECT text FROM position_tape_generate_marker_complete)) = 101 THEN 1 ELSE fail('marker complete 100') END;

UPDATE position_tape_params SET value = '10000' WHERE name = 'length';
SELECT CASE WHEN length((SELECT text FROM position_tape_generate_marker_complete)) = 10003 THEN 1 ELSE fail('marker complete 10000') END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('expected', 'abc');
INSERT INTO position_tape_params VALUES ('received', 'abX');
SELECT CASE WHEN (SELECT position FROM position_tape_find_first_mismatch) = 3 THEN 1 ELSE fail('first mismatch') END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('length', '40');
INSERT INTO position_tape_params
SELECT 'received', text FROM position_tape_generate;
INSERT INTO position_tape_params VALUES ('expected_length', '50');
SELECT CASE WHEN (SELECT truncation_point FROM position_tape_validate) = 41 THEN 1 ELSE fail('truncation point') END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('length', '75');
INSERT INTO position_tape_params
SELECT 'received', text FROM position_tape_generate;
SELECT CASE WHEN (SELECT position FROM position_tape_find_truncation_point) = 76 THEN 1 ELSE fail('find truncation') END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('fragment', substr((SELECT text FROM position_tape_exact WHERE length = 80), 30, 12));
SELECT CASE WHEN (SELECT position FROM position_tape_locate) = 99 THEN 1 ELSE fail('locate fragment') END;

SELECT 'OK sqlite';
