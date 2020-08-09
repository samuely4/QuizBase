-- To start the mysql shell
-- $ mysql -u USERNAME -p
-- You will then be prompted for your password.
-- I will send connection information for the school DB next week.

-- Create a database:
 create database myDB;

-- You can see all of the databases:
-- > show databases;

-- Once you create it, you have to explicitly start using it:
 use myDB;

-- SQL is for the most part case insensitive.
-- Whitespace is not significant, but you will often see SQL formated similarly
-- to the code in this file.

-- Create a table (relation) by specifying a schema.
CREATE TABLE phonebook(
    name VARCHAR(32),
    phone VARCHAR(10),
    address VARCHAR(64)
);
-- View a created table in the mysql shell like so
-- > show tables;

-- You can get a description of the table with
-- > describe phonebook;

-- Add tuple to a relation with `insert`.
INSERT INTO phonebook(
    phone,
    name,
    address
)
VALUES (
    '1234567890',
    'John Doe',
    'Blah Blah'
);
-- Mind the single quotes!

-- Let's add some more data, but this time lets add two records at once.
INSERT INTO phonebook(
    phone,
    name,
    address
)
VALUES ('2345678901', 'Foo Bar', 'Blah Blah Blah'),
       ('3456789012', 'Bin Baz', 'Blah Blah Blah Blah');

-- We can view the rows
SELECT * FROM phonebook;

-- Unless the attribute is constrained, it does not need to be specified.
INSERT INTO phonebook(
    phone,
    name,
    address
)
VALUES (
    '4567890123',
    NULL,
    NULL
);

-- We can update the table to require all of the fields. ALTER TABLE phonebook ALTER COLUMN name SET NOT NULL;
-- But of course that won't work unless we update the latest entry to have a name.UPDATE phonebook SET name='Foopadoop' WHERE phone='4567890123';
-- Now it should work. ALTER TABLE phonebook ALTER COLUMN name SET NOT NULL;
-- And this should no longer work
INSERT INTO phonebook(
    phone,
    name, 
    address
)
VALUES (
    '4567890123',
    NULL,
    NULL
);

-- Let's create another table so we can do more interesting things.
-- (Of course using name here is not realisitic,
--  since names are not usually unique, but we will get to that latter.)
CREATE TABLE photo(
    name VARCHAR(32),
    photo BLOB
);

-- A blob can store 2^16 bytes of arbitrary binary data.
-- A good choice for storing a small photo.

-- Let's insert some data.
INSERT INTO photo(
    name,
    photo
)
VALUES ('Foopadoop', NULL),
       ('John Doe', NULL),
       ('Foo Bar', NULL),
       ('Someone Else', NULL);

-- Some fun queries to try:

SELECT name as fullname FROM phonebook;
-- Renames a column.

SELECT * FROM phonebook p1 NATURAL JOIN photo p2;
-- The `p1`, `p2` are necessary so that MySQL doesn't get confused about the two columns named `name`.

(SELECT * FROM phonebook WHERE name='Foopadoop') UNION (SELECT * FROM phonebook WHERE name='John Doe');
-- Union

SELECT * FROM phonebook CROSS JOIN photo;
-- Product

-- Intersections are not implemented in MySQL, but they are implemented almost everywhere else.
-- They can be simulated like so:
SELECT DISTINCT
    name
FROM
	phonebook
WHERE
    name IN (SELECT name FROM photo);
-- Can you guess at how it works?

