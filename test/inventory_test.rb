require 'minitest/autorun'
require 'date'

require_relative '../inventory.rb'

class InventoryTest < Minitest::Test
  def setup
    @sauce = Item.new('pasta sauce', {date: Date.new(2024, 5, 12)}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2023, 3, 12)})
    @bagels = Item.new('bagels', {date: Date.new(2023, 12, 23), qty: 6}, {date: Date.new(2023, 6, 1), qty: 6})
  end

  def test_new_inventory_ok
    home = Inventory.new('home')
    home.add(@sauce)
    home.add(@bagels)
    assert_includes home.to_s, "pasta sauce x 3"
    assert_includes home.to_s, "bagels x 12"
  end

  def test_new_inventory_not_item
    home = Inventory.new('home')
    assert_raises(TypeError) {
      home.add("pasta sauce")
    }
  end

  def test_remove_item_ok
    home = Inventory.new('home')
    home.add(@sauce)
    home.add(@bagels)
    home.remove('pasta sauce')
    refute_includes home.to_s, "pasta sauce x 3"
    assert_includes home.to_s, "bagels x 12"
  end

  def test_remove_item_not_present
    home = Inventory.new('home')
    home.add(@sauce)
    home.add(@bagels)
    home.remove('apples')
    assert_includes home.to_s, "pasta sauce x 3"
    assert_includes home.to_s, "bagels x 12"
  end

  def test_id
    home = Inventory.new('home')
    home.set_id(3)
    assert home.id.class == Integer
  end

  def test_item_by_name
    home = Inventory.new('home')
    home.add(@sauce)
    home.add(@bagels)
    assert_equal Item, home.item('bagels').class
  end

  def test_item_by_item_id
    home = Inventory.new('home')
    home.add(@sauce)
    home.add(@bagels)
    assert_equal Item, home.item_id(1).class
    assert_equal 'bagels', home.item_id(1).name
  end

  def test_each_no_block
    home = Inventory.new('home')
    home.add(@sauce)
    home.add(@bagels)
    assert_equal 'pasta sauce', home.each[0].name
    assert_equal 'bagels', home.each[1].name
  end

  def test_each_block
    home = Inventory.new('home')
    home.add(@sauce)
    home.add(@bagels)
    output = ""
    home.each { |item| output += item.name }
    assert_equal 'pasta saucebagels', output
  end

  def test_size
    home = Inventory.new('home')
    home.add(@sauce)
    home.add(@bagels)
    assert_equal 2, home.size
    home.remove('bagels')
    assert_equal 1, home.size
  end

  def test_get_item_id
    home = Inventory.new('home')
    home.add(@sauce.dup)
    home.add(@bagels.dup)
    assert_equal 2, home.get_item_id
  end
end