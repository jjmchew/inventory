require 'minitest/autorun'
require 'date'

require_relative '../date.rb'

class DateTest < Minitest::Test
  include DateHelper
  
  def test_1
    past_date = Date.today - 12
    p past_date
    sauce = Item.new('pasta sauce', {date: past_date}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2023, 3, 12)})
    assert_equal true, highlight_date?(sauce)
  end
  
  def test_2
    past_date = Date.today - 3
    sauce = Item.new('pasta sauce', {date: past_date}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2024, 3, 12)})
    assert_equal true, highlight_date?(sauce)
  end

  def test_3
    past_date = Date.today - 7
    sauce = Item.new('pasta sauce', {date: past_date}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2024, 3, 12)})
    assert_equal true, highlight_date?(sauce)
  end

  def test_4
    future_date = Date.today + 7
    sauce = Item.new('pasta sauce', {date: future_date}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2024, 3, 12)})
    assert_equal true, highlight_date?(sauce)
  end

  def test_5
    future_date = Date.today + 8
    sauce = Item.new('pasta sauce', {date: future_date}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2024, 3, 12)})
    assert_equal false, highlight_date?(sauce)
  end

  def test_6
    future_date = Date.today + 21
    sauce = Item.new('pasta sauce', {date: future_date}, {date: Date.new(2025, 11, 17)}, {date: Date.new(2024, 3, 12)})
    assert_equal false, highlight_date?(sauce)
  end
end
