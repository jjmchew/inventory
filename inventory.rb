require_relative 'item.rb'

class Inventory
  attr_reader :id, :name

  def initialize(name)
    @name = name
    @inventory = []
  end

  # add item to inventory
  def add(item)
    raise TypeError, 'Item not of correct type' if item.class != Item
    new_item = item.dup
    id = new_item.id || get_item_id
    new_item.set_id(id)
    @inventory << new_item
  end

  # remove item from inventory
  def remove(item_name)
    idx = find_name_idx(item_name)
    @inventory.delete_at(idx) unless idx.nil?
  end

  # iterate through (get) all items in inventory
  def each(&block)
    @inventory.each do |item|
      block.call(item) if block_given?
    end
    @inventory
  end

  # iterate with an index
  def each_with_index(&block)
    @inventory.each_with_index do |item, index|
      block.call(item, index) if block_given?
    end
    @inventory
  end

  # expose an item (named) in the inventory for updates
  def item(name)
    idx = find_name_idx(name)
    @inventory[idx]
  end

  #expose an item (by item_id) in the inventory for updates
  def item_id(num)
    idx = find_id_idx(num)
    @inventory[idx]
  end

  # create string output of inventory
  def to_s
    out = []
    @inventory.each do |item|
      out << "#{item.name} x #{item.total}" 
    end
    out.join("\n")
  end

  # return number of items in inventory
  def size
    @inventory.size
  end

  # allow id for list to be set
  def set_id(num)
    @id = num
  end

  # get next item_id
  def get_item_id
    max_id = nil
    @inventory.each do |item|
      max_id = item.id if max_id.nil? || item.id > max_id
    end
    return 0 if max_id.nil?
    max_id + 1
  end

  private

  # find index of an item - name given
  def find_name_idx(name)
    idx = nil
    @inventory.each_with_index do |item, index|
      idx = index if item.name == name
    end
    idx
  end

  # find index of an item - id given
  def find_id_idx(id)
    idx = nil
    @inventory.each_with_index do |item, index|
      idx = index if item.id == id
    end
    idx
  end
end

