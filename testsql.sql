SELECT * FROM items_inv
WHERE id = 
(SELECT id AS min_id
FROM items_inv
WHERE item_id = 1
ORDER BY item_date
LIMIT 1);