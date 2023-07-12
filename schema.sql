-- DROP TABLE IF EXISTS items, items_inv, invs, invs_invs CASCADE;

CREATE TABLE items (
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE items_inv (
  id serial PRIMARY KEY,
  item_id integer NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  item_date date DEFAULT NOW(),
  qty integer NOT NULL DEFAULT 1
);

CREATE TABLE invs (
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE invs_invs (
  id serial PRIMARY KEY,
  item_id integer NOT NULL UNIQUE REFERENCES items(id) ON DELETE CASCADE,
  inv_id integer NOT NULL REFERENCES invs(id) ON DELETE CASCADE
);


-- Sample data

INSERT INTO items
  (name) VALUES
  ('pasta sauce'),
  ('chips'),
  ('tp');

INSERT INTO items_inv
  (item_id, item_date, qty) VALUES
  (1, '2025-09-01', 4),
  (1, '2025-12-20', 2),
  (2, '2023-06-13', 2),
  (3, '2023-07-11', 16);

INSERT INTO invs
  (name) VALUES
  ('Food'),
  ('Stuff');

INSERT INTO invs_invs
  (item_id, inv_id) VALUES
  (1, 1), (2, 1),
  (3, 2);

