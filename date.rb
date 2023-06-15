require 'date'
require_relative './item.rb'

module DateHelper
  def highlight_date?(item)
    item.each do |obj|
      return true if Date.today >= obj[:date] # expiry passed
      return true if (obj[:date] - 7) <= Date.today # expiry will pass in a week
    end
    false
  end
end
