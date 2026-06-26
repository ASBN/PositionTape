.bail on
.read languages/sqlite/src/position_tape.sql

DROP TABLE IF EXISTS position_tape_assertions;
CREATE TEMP TABLE position_tape_assertions (
  message TEXT CHECK (message IS NULL)
);

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('length', '0');
INSERT INTO position_tape_assertions
SELECT CASE WHEN (SELECT text FROM position_tape_generate) = '' THEN NULL ELSE 'zero length' END;

UPDATE position_tape_params SET value = '11' WHERE name = 'length';
INSERT INTO position_tape_assertions
SELECT CASE WHEN (SELECT text FROM position_tape_generate) = '12345678911' THEN NULL ELSE 'basic generation' END;

UPDATE position_tape_params SET value = '100' WHERE name = 'length';
INSERT INTO position_tape_assertions
SELECT CASE WHEN length((SELECT text FROM position_tape_generate)) = 100 THEN NULL ELSE 'exact boundary' END;
INSERT INTO position_tape_assertions
SELECT CASE WHEN length((SELECT text FROM position_tape_generate_marker_complete)) = 101 THEN NULL ELSE 'marker complete 100' END;

UPDATE position_tape_params SET value = '10000' WHERE name = 'length';
INSERT INTO position_tape_assertions
SELECT CASE WHEN length((SELECT text FROM position_tape_generate_marker_complete)) = 10003 THEN NULL ELSE 'marker complete 10000' END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('expected', 'abc');
INSERT INTO position_tape_params VALUES ('received', 'abX');
INSERT INTO position_tape_assertions
SELECT CASE WHEN (SELECT position FROM position_tape_find_first_mismatch) = 3 THEN NULL ELSE 'first mismatch' END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('length', '40');
INSERT INTO position_tape_params
SELECT 'received', text FROM position_tape_generate;
INSERT INTO position_tape_params VALUES ('expected_length', '50');
INSERT INTO position_tape_assertions
SELECT CASE WHEN (SELECT truncation_point FROM position_tape_validate) = 41 THEN NULL ELSE 'truncation point' END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('length', '75');
INSERT INTO position_tape_params
SELECT 'received', text FROM position_tape_generate;
INSERT INTO position_tape_assertions
SELECT CASE WHEN (SELECT position FROM position_tape_find_truncation_point) = 76 THEN NULL ELSE 'find truncation' END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('length', '80');
INSERT INTO position_tape_params
SELECT 'fragment', substr(text, 30, 12) FROM position_tape_generate;
INSERT INTO position_tape_assertions
SELECT CASE WHEN (SELECT position FROM position_tape_locate) = 30 THEN NULL ELSE 'locate fragment' END;

SELECT 'OK sqlite';
