.read languages/sqlite/src/position_tape.sql

INSERT INTO position_tape_params VALUES ('length', '120');
SELECT text FROM position_tape_generate;

DELETE FROM position_tape_params;
INSERT INTO position_tape_params VALUES ('fragment', '9910');
SELECT position FROM position_tape_locate;
