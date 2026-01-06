# IV1351 – Seminar 1 (Task 1 / 5.1) – Setup instructions (psql)

This folder contains:
- `create.sql` – creates the schema (tables, PK/FK, constraints, indexes, trigger).
- `insert.sql` – inserts a small dataset for verification and Seminar 2.

---

## 1 Start psql (PostgreSQL client)

1. start the postgres client
```
psql postgres;
```

2. create the database
```
CREATE DATABASE iv1351;
```
3. connect to the database
```
\c iv1351;
```

4. Create schema (tables + constraints + trigger)
```
\i < /path/to/create.sql >
```

5. insert the generated data into the created database
```
\i < /path/to/insert.sql >
```

## For reset of the database [during development]
1. Just run again:
```
\i create.sql
\i insert.sql
```

## Exit psql
1. 
```
\q
```




