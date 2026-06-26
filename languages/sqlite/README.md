# PositionTape for sqlite

Status: Level 2 implementation.

SQLite does not provide parameterized stored functions in a plain `.sql` file,
so this implementation exposes the API as TEMP views backed by the
`position_tape_params` TEMP table.

Load the views, set the required parameters, then query the corresponding view:

```sql
.read languages/sqlite/src/position_tape.sql
INSERT INTO position_tape_params VALUES ('length', '120');
SELECT text FROM position_tape_generate;
```

Run the local checks with:

```powershell
Get-Content languages/sqlite/tests/position_tape_tests.sql | sqlite3
```
