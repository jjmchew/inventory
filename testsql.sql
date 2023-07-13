SELECT invs.name AS invs_name,
       invs.id AS invs_id,
       items.name AS items_name,
       items.id AS items_id,
       item_date,
       qty
FROM invs_invs
JOIN items ON item_id = items.id
JOIN items_inv ON items_inv.item_id = items.id
FULL JOIN invs ON inv_id = invs.id
WHERE inv_id = 1;

-- SELECT * FROM invs WHERE id = 3;