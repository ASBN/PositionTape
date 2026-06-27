.bail on
.load ./languages/sqlite/extensions/sha256/sha256_extension.dll sqlite3_sha256_init
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

INSERT INTO position_tape_assertions
SELECT CASE WHEN sha256('') = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855' THEN NULL ELSE 'sha256 empty' END;

INSERT INTO position_tape_assertions
SELECT CASE WHEN sha256('abc') = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad' THEN NULL ELSE 'sha256 abc' END;

INSERT INTO position_tape_assertions
SELECT CASE WHEN sha256('PositionTape') = '55fc0a7c26db83dc2f2aca556e9803ff6d90dcda6c2ad59a69687054ba33abc5' THEN NULL ELSE 'sha256 project name' END;

INSERT INTO position_tape_assertions
SELECT CASE WHEN sha256('3123456789412345') = 'babe07aaad1e1044963518b077f853b6016e6133c960bfd953058f7302d54e5a' THEN NULL ELSE 'sha256 canonical fragment' END;

INSERT INTO position_tape_assertions
SELECT CASE WHEN sha256('Niño-posición-✓') = 'ed95c68f09b2639a60011ca685de6bff3ac13ad7a8fef9a8161c108c6d214bab' THEN NULL ELSE 'sha256 utf8 non-ascii' END;

INSERT INTO position_tape_assertions
SELECT CASE WHEN sha256(NULL) IS NULL THEN NULL ELSE 'sha256 null' END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('fragment', '3123456789412345');
INSERT INTO position_tape_assertions
SELECT CASE WHEN (SELECT hash FROM position_tape_hash_fragment) = 'babe07aaad1e1044963518b077f853b6016e6133c960bfd953058f7302d54e5a' THEN NULL ELSE 'hash fragment view' END;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('window_size', '16');
INSERT INTO position_tape_assertions
SELECT CASE WHEN EXISTS (
  SELECT 1
  FROM position_tape_build_window_index
  WHERE hash = 'babe07aaad1e1044963518b077f853b6016e6133c960bfd953058f7302d54e5a'
    AND position = 30
) THEN NULL ELSE 'build window index' END;

INSERT INTO position_tape_params VALUES ('fragment_hash', 'BABE07AAAD1E1044963518B077F853B6016E6133C960BFD953058F7302D54E5A');
INSERT INTO position_tape_assertions
SELECT CASE WHEN EXISTS (
  SELECT 1
  FROM position_tape_locate_by_hash
  WHERE position = 30
) THEN NULL ELSE 'locate by hash' END;

SELECT 'OK sqlite';
