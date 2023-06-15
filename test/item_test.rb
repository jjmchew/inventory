require 'minitest/autorun'
require 'date'

require_relative '../item.rb'

class ItemTest < Minitest::Test
  def test_new_item_no_name
    assert_raises(ArgumentError) {
      Item.new
    }
  end

  def test_new_item_no_dates
    sauce = Item.new('pasta sauce')
    assert_equal 0, sauce.total
    assert_equal '', sauce.to_s
  end

  def test_new_item_not_obj
    assert_raises(ArgumentError) {
      Item.new('pasta sauce', '2023-7-1')
    }
  end

  def test_new_item_no_qty_ok
    sauce = Item.new('pasta sauce', {date: Date.new(2024, 5, 12)}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2023, 3, 12)})
    assert_equal 3, sauce.total
    assert_equal '2023-03-12, 2024-05-12, 2025-11-17', sauce.to_s
  end

  def test_add_item_not_date
    sauce = Item.new('pasta sauce', {date: Date.new(2024, 5, 12)}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2023, 3, 12)})
    assert_raises(ArgumentError) {
      sauce.add('2023-12-23')
    }
  end

  def test_add_item_no_qty_ok
    sauce = Item.new('pasta sauce', {date: Date.new(2024, 5, 12)}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2023, 3, 12)})
    sauce.add({date: Date.new(2024, 7, 1)})
    assert_equal '2023-03-12, 2024-05-12, 2024-07-01, 2025-11-17', sauce.to_s
  end

  def test_add_item_no_qty_ok
    bagels = Item.new('bagels', {date: Date.new(2023, 12, 23), qty: 6}, {date: Date.new(2023, 6, 1), qty: 6})
    bagels.add({date: Date.new(2023, 4, 1), qty: 12})
    assert_equal 24, bagels.total
    assert_equal '2023-04-01 x12, 2023-06-01 x6, 2023-12-23 x6', bagels.to_s
  end

  def test_use_item_no_date_qty_1
    sauce = Item.new('pasta sauce', {date: Date.new(2024, 5, 12)}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2023, 3, 12)})
    sauce.use
    assert_equal 2, sauce.total
    assert_equal '2024-05-12, 2025-11-17', sauce.to_s
  end

  def test_use_item_no_date_qty_more_than
    bagels = Item.new('bagels', {date: Date.new(2023, 12, 23), qty: 6}, {date: Date.new(2023, 6, 1), qty: 6})
    bagels.use(7)
    assert_equal 5, bagels.total
    assert_equal '2023-12-23 x5', bagels.to_s
  end

  def test_use_item_no_date_qty_less_than
    bagels = Item.new('bagels', {date: Date.new(2023, 12, 23), qty: 6}, {date: Date.new(2023, 6, 1), qty: 6})
    bagels.use(3)
    assert_equal 9, bagels.total
    assert_equal '2023-06-01 x3, 2023-12-23 x6', bagels.to_s
  end

  def test_list
    bagels = Item.new('bagels', {date: Date.new(2023, 12, 23), qty: 6}, {date: Date.new(2023, 6, 1), qty: 6})
    assert_includes bagels.list, '2023-06-01 x6'
    assert_includes bagels.list, '2023-12-23 x6'
  end

  def test_set_id
    bagels = Item.new('bagels', {date: Date.new(2023, 12, 23), qty: 6}, {date: Date.new(2023, 6, 1), qty: 6})
    bagels.set_id(3)
    assert_equal 3, bagels.id
  end
end
