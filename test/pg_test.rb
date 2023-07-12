ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'

require_relative '../persist_pg.rb'
require_relative '../db_class_helpers.rb'

class PGTest < Minitest::Test
  include DbClassHelpers
  def setup
    @db = PersistPG.new('PGTEST')
  end

  def teardown
    @db.close_testdb
  end

  def test_remove_list
    @db.remove_list(2)

    lists = @db.read_inventories
    assert_equal 1, lists.size
    assert_equal 'Food', lists.first.name
    refute_equal 'tp', lists.last.name
  end

  def test_read_inventories
    lists = @db.read_inventories

    assert_equal 2, lists.size
    assert_equal 'Food', lists.first.name
    assert_equal 'Stuff', lists.last.name
    assert_equal 'chips', lists.first.item_id(2).name
    assert_equal 'tp', lists.last.item_id(3).name
  end

  def test_get_list_1
    list = @db.get_list(1)

    assert_equal 'Food', list.name
    assert_equal 2, list.size
    assert_equal 1, list.id
    assert_equal 2, list.item('chips').id
    assert_equal 1, list.item('pasta sauce').id
  end

  def test_get_list_2
    list = @db.get_list(2)

    assert_equal 'Stuff', list.name
    assert_equal 1, list.size
    assert_equal 2, list.id
    assert_equal 3, list.item('tp').id
  end

  def test_remove_item
    @db.remove_item(1, 2)

    lists = @db.read_inventories
    assert_equal 2, lists.size
    assert_equal 1, lists.first.size
    assert_includes lists.first.to_s, 'pasta sauce x 6'
    refute_includes lists.first.to_s, 'chips'
  end

  def test_use_item
    @db.use_item(nil, 2)

    lists = @db.read_inventories
    assert_includes lists.first.to_s, 'chips x 1'
    refute_includes lists.last.to_s, 'chips'

    @db.use_item(nil, 2)

    lists = @db.read_inventories
    refute_includes lists.first.to_s, 'chips'
    refute_includes lists.last.to_s, 'chips'
  end

  def test_add_qty_to_item
    new_obj = {
      date: Date.new(2023, 8, 8),
      qty: 3
    }
    @db.add_qty_to_item(nil, 2, new_obj)

    lists = @db.read_inventories
    assert_includes lists.first.to_s, 'chips x 5'
    refute_includes lists.last.to_s, 'chips'
  end

  def test_add_new_item
    new_item = Item.new('soap', { date: Date.new(2023, 8, 3), qty: 10 } )
    @db.add_new_item(2, new_item)

    lists = @db.read_inventories
    assert_includes lists.last.to_s, 'soap x 10'
    refute_includes lists.first.to_s, 'soap'
  end

  def test_new_list
    new_list = Inventory.new('Equipment')
    @db.new_list(new_list)

    lists = @db.read_inventories
    assert_equal 'Food', lists.first.name
    assert_equal 'Stuff', lists[1].name
    assert_equal 'Equipment', lists[2].name
    assert_kind_of Inventory, lists[2]
  end
end
