SELECT * FROM country;
SELECT * FROM information_schema.table_constraints;
SELECT table_name, constraint_name, constraint_type FROM information_schema.table_constraints where constraint_type = 'PRIMARY KEY';
