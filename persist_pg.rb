require 'pg'
require_relative 'db_class_helpers'

class PersistPG
  include DbClassHelpers

  def initialize(mode, logger=nil)
    if mode == 'DEV'
      @db = PG.connect(dbname: 'jjmchewa_inventory')
      @logger = logger
    elsif mode == 'PGTEST'
      @db = PG.connect(dbname: 'postgres')
      @db.exec('CREATE DATABASE testdb;')

      @db = PG.connect(dbname: 'testdb') 
      setup_testdb
    else
      @db = PG.connect(dbname: 'jjmchewa_inventory', uesr: 'jjmchewa_pg', password: 'db123')
      @logger = logger
    end
  end

  def query(statement, *params)
    @logger.info("#{statement}: #{params}") unless @logger.nil?
    @db.exec_params(statement, params)
  end

  def read_inventories
    # puts "read_inventories"
    sql = <<~SQL
      SELECT * FROM invs;
    SQL
    str_ids = query(sql).field_values('id')
    get_lists(str_ids)
  end

  def remove_list(list_id)
    sql = <<~SQL
      DELETE FROM invs WHERE id = $1;
    SQL
    result = query(sql, list_id)
  end

  def get_list(list_id)
    sql = <<~SQL
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
      WHERE inv_id = $1;
    SQL
    result = query(sql, list_id)
    if result.ntuples > 0 then GetList.new(result).list
    else
      result2 = query('SELECT * FROM invs WHERE id = $1;', list_id)
      empty_list = Inventory.new(result2.field_values('name').first)
      empty_list.set_id(result2.field_values('id').first.to_i)
      empty_list
    end
  end

  def new_list(inventory)
    sql = 'INSERT INTO invs (name) VALUES ($1)'
    query(sql, inventory.name)
  end

  def add_new_item(list_id, new_item)
    sql1 = 'INSERT INTO items (name) VALUES ($1)'
    query(sql1, new_item.name)

    # get item_id
    sql1a = 'SELECT id FROM items WHERE name = $1'
    item_id = query(sql1a, new_item.name).field_values('id').first.to_i

    sql2 = <<~SQL
      INSERT INTO items_inv (item_id, item_date, qty) VALUES ($1, $2, $3)
    SQL
    date = nil
    qty = nil
    new_item.each do |obj|
      date = obj[:date]
      qty = obj[:qty] || 1
    end
    query(sql2, item_id, date, qty)

    sql3 = 'INSERT INTO invs_invs (item_id, inv_id) VALUES ($1, $2)'
    query(sql3, item_id, list_id)
  end

  def add_qty_to_item(_, item_id, obj)
    sql = <<~SQL
      INSERT INTO items_inv (item_id, item_date, qty) VALUES
        ($1, $2, $3);
    SQL
    query(sql, item_id, obj[:date], obj[:qty])
  end

  def use_item(_, item_id)
    # find qty for min (by date) entry
    sql1 = <<~SQL
      SELECT id,
             qty
      FROM items_inv
      WHERE id =
      (SELECT id AS min_id FROM items_inv WHERE item_id = $1 ORDER BY item_date LIMIT 1);
    SQL
    result1 = query(sql1, item_id)
    items_inv_id = result1.field_values('id').first.to_i
    qty = result1.field_values('qty').first.to_i

    # remove / update appropriate entry
    if qty == 1
      # sql2 = <<~SQL
        # DELETE FROM items_inv WHERE id = $1;
      # SQL
      # query(sql2, items_inv_id)
      remove_item(_, item_id)
    else
      sql2 = <<~SQL
        UPDATE items_inv SET qty = $1 WHERE id = $2;
      SQL
      query(sql2, qty-1, items_inv_id)
    end
  end

  def remove_item(_, item_id)
    # sql = <<~SQL
      # DELETE FROM invs_invs
        # WHERE inv_id = $1
        # AND item_id = $2;
    # SQL
    # query(sql, list_id, item_id)

    sql = <<~SQL
      DELETE FROM items WHERE id = $1;
    SQL
    query(sql, item_id)
  end

  def close_testdb
    drop_testdb
  end

  private

  def setup_testdb
    sql = File.open('schema.sql') { |file| file.read }
    @db.exec(sql)
  end

  def drop_testdb
    @db.close
    db = PG.connect(dbname: 'postgres')
    db.exec('DROP DATABASE testdb;')
  end

  def get_lists(str_ids)
    lists = []
    str_ids.each do |str_id|
      lists << get_list(str_id.to_i)
    end
    lists
  end
end
