DROP TABLE IF EXISTS position_tape_params;
DROP VIEW IF EXISTS position_tape_generate;
DROP VIEW IF EXISTS position_tape_marker_complete_length;
DROP VIEW IF EXISTS position_tape_generate_marker_complete;
DROP VIEW IF EXISTS position_tape_find_first_mismatch;
DROP VIEW IF EXISTS position_tape_validate;
DROP VIEW IF EXISTS position_tape_find_truncation_point;
DROP VIEW IF EXISTS position_tape_locate;

CREATE TEMP TABLE position_tape_params (
  name TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TEMP VIEW position_tape_generate AS
WITH RECURSIVE
  input(length) AS (
    SELECT CAST(value AS INTEGER)
    FROM position_tape_params
    WHERE name = 'length'
  ),
  tape(cursor, remaining, output) AS (
    SELECT 1, length, ''
    FROM input
    UNION ALL
    SELECT
      CASE
        WHEN cursor % 10 = 0 THEN cursor + length(CAST(cursor / 10 AS TEXT))
        ELSE cursor + 1
      END,
      CASE
        WHEN cursor % 10 = 0 THEN remaining - length(substr(CAST(cursor / 10 AS TEXT), 1, remaining))
        ELSE remaining - 1
      END,
      output ||
      CASE
        WHEN cursor % 10 = 0 THEN substr(CAST(cursor / 10 AS TEXT), 1, remaining)
        ELSE CAST(cursor % 10 AS TEXT)
      END
    FROM tape
    WHERE remaining > 0
  )
SELECT output AS text
FROM tape
WHERE remaining = 0;

CREATE TEMP VIEW position_tape_marker_complete_length AS
WITH RECURSIVE
  input(length) AS (
    SELECT CAST(value AS INTEGER)
    FROM position_tape_params
    WHERE name = 'length'
  ),
  scan(cursor, complete_length, done) AS (
    SELECT 1, length, 0
    FROM input
    UNION ALL
    SELECT
      CASE
        WHEN cursor % 10 = 0 THEN cursor + length(CAST(cursor / 10 AS TEXT))
        ELSE cursor + 1
      END,
      CASE
        WHEN cursor % 10 = 0
          AND complete_length < cursor + length(CAST(cursor / 10 AS TEXT)) - 1
          THEN cursor + length(CAST(cursor / 10 AS TEXT)) - 1
        ELSE complete_length
      END,
      CASE
        WHEN cursor % 10 = 0
          AND complete_length < cursor + length(CAST(cursor / 10 AS TEXT)) - 1
          THEN 1
        WHEN cursor > complete_length THEN 1
        ELSE 0
      END
    FROM scan
    WHERE done = 0
  )
SELECT complete_length AS length
FROM scan
WHERE done = 1
ORDER BY cursor
LIMIT 1;

CREATE TEMP VIEW position_tape_generate_marker_complete AS
WITH RECURSIVE
  input(length) AS (
    SELECT length
    FROM position_tape_marker_complete_length
  ),
  tape(cursor, remaining, output) AS (
    SELECT 1, length, ''
    FROM input
    UNION ALL
    SELECT
      CASE
        WHEN cursor % 10 = 0 THEN cursor + length(CAST(cursor / 10 AS TEXT))
        ELSE cursor + 1
      END,
      CASE
        WHEN cursor % 10 = 0 THEN remaining - length(substr(CAST(cursor / 10 AS TEXT), 1, remaining))
        ELSE remaining - 1
      END,
      output ||
      CASE
        WHEN cursor % 10 = 0 THEN substr(CAST(cursor / 10 AS TEXT), 1, remaining)
        ELSE CAST(cursor % 10 AS TEXT)
      END
    FROM tape
    WHERE remaining > 0
  )
SELECT output AS text
FROM tape
WHERE remaining = 0;

CREATE TEMP VIEW position_tape_find_first_mismatch AS
WITH RECURSIVE
  input(expected, received) AS (
    SELECT
      (SELECT value FROM position_tape_params WHERE name = 'expected'),
      (SELECT value FROM position_tape_params WHERE name = 'received')
  ),
  scan(position, expected, received) AS (
    SELECT 1, expected, received
    FROM input
    UNION ALL
    SELECT position + 1, expected, received
    FROM scan
    WHERE position <= max(length(expected), length(received))
      AND coalesce(substr(expected, position, 1), '') = coalesce(substr(received, position, 1), '')
  )
SELECT
  position,
  nullif(substr(expected, position, 1), '') AS expected,
  nullif(substr(received, position, 1), '') AS received
FROM scan
WHERE position <= max(length(expected), length(received))
  AND coalesce(substr(expected, position, 1), '') != coalesce(substr(received, position, 1), '')
LIMIT 1;

CREATE TEMP VIEW position_tape_validate AS
WITH
  input(received, expected_length) AS (
    SELECT
      (SELECT value FROM position_tape_params WHERE name = 'received'),
      CAST((SELECT value FROM position_tape_params WHERE name = 'expected_length') AS INTEGER)
  ),
  expected_tape(text) AS (
    WITH RECURSIVE tape(cursor, remaining, output) AS (
      SELECT 1, expected_length, ''
      FROM input
      UNION ALL
      SELECT
        CASE
          WHEN cursor % 10 = 0 THEN cursor + length(CAST(cursor / 10 AS TEXT))
          ELSE cursor + 1
        END,
        CASE
          WHEN cursor % 10 = 0 THEN remaining - length(substr(CAST(cursor / 10 AS TEXT), 1, remaining))
          ELSE remaining - 1
        END,
        output ||
        CASE
          WHEN cursor % 10 = 0 THEN substr(CAST(cursor / 10 AS TEXT), 1, remaining)
          ELSE CAST(cursor % 10 AS TEXT)
        END
      FROM tape
      WHERE remaining > 0
    )
    SELECT output
    FROM tape
    WHERE remaining = 0
  ),
  mismatch AS (
    WITH RECURSIVE scan(position, expected, received) AS (
      SELECT 1, text, received
      FROM expected_tape, input
      UNION ALL
      SELECT position + 1, expected, received
      FROM scan
      WHERE position <= max(length(expected), length(received))
        AND coalesce(substr(expected, position, 1), '') = coalesce(substr(received, position, 1), '')
    )
    SELECT
      position,
      nullif(substr(expected, position, 1), '') AS expected,
      nullif(substr(received, position, 1), '') AS received
    FROM scan
    WHERE position <= max(length(expected), length(received))
      AND coalesce(substr(expected, position, 1), '') != coalesce(substr(received, position, 1), '')
    LIMIT 1
  )
SELECT
  CASE WHEN NOT EXISTS (SELECT 1 FROM mismatch) THEN 1 ELSE 0 END AS is_valid,
  expected_length,
  length(received) AS received_length,
  CASE
    WHEN EXISTS (SELECT 1 FROM mismatch)
      AND length(received) < expected_length
      AND substr((SELECT text FROM expected_tape), 1, length(received)) = received
      THEN length(received) + 1
    ELSE NULL
  END AS truncation_point,
  (SELECT position FROM mismatch) AS first_mismatch_position,
  (SELECT expected FROM mismatch) AS first_mismatch_expected,
  (SELECT received FROM mismatch) AS first_mismatch_received
FROM input;

CREATE TEMP VIEW position_tape_find_truncation_point AS
WITH
  input(received) AS (
    SELECT value
    FROM position_tape_params
    WHERE name = 'received'
  ),
  expected_tape(text) AS (
    WITH RECURSIVE tape(cursor, remaining, output) AS (
      SELECT 1, length(received), ''
      FROM input
      UNION ALL
      SELECT
        CASE
          WHEN cursor % 10 = 0 THEN cursor + length(CAST(cursor / 10 AS TEXT))
          ELSE cursor + 1
        END,
        CASE
          WHEN cursor % 10 = 0 THEN remaining - length(substr(CAST(cursor / 10 AS TEXT), 1, remaining))
          ELSE remaining - 1
        END,
        output ||
        CASE
          WHEN cursor % 10 = 0 THEN substr(CAST(cursor / 10 AS TEXT), 1, remaining)
          ELSE CAST(cursor % 10 AS TEXT)
        END
      FROM tape
      WHERE remaining > 0
    )
    SELECT output
    FROM tape
    WHERE remaining = 0
  ),
  mismatch AS (
    WITH RECURSIVE scan(position, expected, received) AS (
      SELECT 1, text, received
      FROM expected_tape, input
      UNION ALL
      SELECT position + 1, expected, received
      FROM scan
      WHERE position <= max(length(expected), length(received))
        AND coalesce(substr(expected, position, 1), '') = coalesce(substr(received, position, 1), '')
    )
    SELECT position
    FROM scan
    WHERE position <= max(length(expected), length(received))
      AND coalesce(substr(expected, position, 1), '') != coalesce(substr(received, position, 1), '')
    LIMIT 1
  )
SELECT coalesce((SELECT position FROM mismatch), length(received) + 1) AS position
FROM input;

CREATE TEMP VIEW position_tape_locate AS
WITH
  input(fragment) AS (
    SELECT value
    FROM position_tape_params
    WHERE name = 'fragment'
  ),
  search_length(length) AS (SELECT 100003),
  tape(text) AS (
    WITH RECURSIVE gen(cursor, remaining, output) AS (
      SELECT 1, length, ''
      FROM search_length
      UNION ALL
      SELECT
        CASE
          WHEN cursor % 10 = 0 THEN cursor + length(CAST(cursor / 10 AS TEXT))
          ELSE cursor + 1
        END,
        CASE
          WHEN cursor % 10 = 0 THEN remaining - length(substr(CAST(cursor / 10 AS TEXT), 1, remaining))
          ELSE remaining - 1
        END,
        output ||
        CASE
          WHEN cursor % 10 = 0 THEN substr(CAST(cursor / 10 AS TEXT), 1, remaining)
          ELSE CAST(cursor % 10 AS TEXT)
        END
      FROM gen
      WHERE remaining > 0
    )
    SELECT output
    FROM gen
    WHERE remaining = 0
  )
SELECT
  CASE
    WHEN fragment = '' THEN 1
    WHEN instr(text, fragment) = 0 THEN -1
    ELSE instr(text, fragment)
  END AS position
FROM input, tape;
