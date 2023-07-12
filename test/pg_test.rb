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
end
