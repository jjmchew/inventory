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
      JOIN invs ON inv_id = invs.id
      JOIN items ON item_id = items.id
      JOIN items_inv ON items_inv.item_id = items.id
      WHERE inv_id = $1;
    SQL
    result = query(sql, list_id)
    GetList.new(result).list
  end

  def write_list(list_id)
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
