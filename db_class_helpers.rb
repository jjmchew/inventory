require_relative 'item'
require_relative 'inventory'

module DbClassHelpers
  class GetList
    attr_reader :list

    def initialize(result)
      @result = result
      list_result_to_objs
      create_inventory
      add_items
    end

    private

    def list_result_to_objs
      # process result into objects
      headers = @result.fields
      objs = []
      @result.values.each do |row|
        obj = {}
        row.each_with_index { |data, idx| obj[headers[idx]] = data }
        objs << obj
      end
      @objs = objs
    end

    def create_inventory
      # create Inventory
      inv_name = @result.field_values('invs_name').first
      inv_id = @result.field_values('invs_id').first.to_i

      @list = Inventory.new(inv_name)
      @list.set_id(inv_id)
    end

    def add_items
      # create Items
      items_names = @result.field_values('items_name').uniq
      items_names.each do |item_name|
        item = Item.new(item_name)
        item.set_id(get_items_id(item_name))

        @objs.each do |obj|
          if obj['items_name'] == item_name
            item.add({
              date: make_date(obj['item_date']),
              qty: obj['qty'].to_i
            })
          end
        end
        @list.add(item)
      end
    end

    def get_items_id(item_name)
      @objs.each do |obj|
        return obj['items_id'].to_i if obj['items_name'] == item_name
      end
    end

    def make_date(date_str)
      Date.strptime(date_str, '%Y-%m-%d')
    end

  end # class

end # module
