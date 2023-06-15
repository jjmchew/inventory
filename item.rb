require 'date'

class Item
  attr_reader :name, :id

  def initialize(name, *objs)
    @name = name
    @inventory = assign(objs)
    # where an obj is { date: Date.new, qty: # } (qty is optional, assign_obj assigns 1 if not given)
  end

  # iterates through inventory to total remaining qty
  def total
    total = 0
    each { |obj| total += obj[:qty] }
    total
  end

  # returns a string of remaining expiries
  def to_s
    list.join(', ')
  end

  # returns an array of remaining date / qty
  def list
    out = []
    each do |obj| 
      if obj[:qty] > 1
        out << "#{obj[:date]} x #{obj[:qty]}"
      else
        out << "#{obj[:date]}"
      end
    end
    out
  end

   # helper method to iterate through inventory array, returns inventory
   def each(&block)
    @inventory.each do |obj|
      block.call(obj) if block_given?
    end
    @inventory
  end

  # add an obj to inventory, then sort
  def add(obj)
    assign_obj(obj)
    sort_inventory
  end

  # reduce the inventory as items are used
  def use(qty=1)
    raise ArgumentError, "tried to use more than available" if qty > total
    remaining = qty
    
    loop do
      if @inventory.first[:qty] <= remaining
        remaining -= @inventory.first[:qty]
        @inventory.shift
      else
        @inventory.first[:qty] -= remaining
        remaining = 0
      end

      break if remaining == 0 || @inventory.empty?
    end
  end

  # allow an id num to be set
  def set_id(num)
    @id = num
  end

  private

  def assign_obj(obj)
    # check obj for proper date class, assign a qty of 1 if not given
    raise ArgumentError, "item format incorrect" if obj.class != Hash
    raise ArgumentError, "item format incorrect" if obj[:date].class != Date
    obj[:qty] = 1 if obj[:qty].nil?
    @inventory << obj
  end

  def assign(objs)
    # assign all obj given on instantiation from initialize (given as array)
    @inventory = []
    objs.each { |obj| assign_obj(obj) }
    sort_inventory
  end

  def sort_inventory
    # sort inventory by expiry date
    @inventory = @inventory.sort_by { |hash| hash[:date] }
  end
end
