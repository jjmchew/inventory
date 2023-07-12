require 'yaml'

class PersistYML
  def initialize(env)
    @env = env
  end

  def data_path
    if @env['RACK_ENV'] == 'test'
      File.expand_path('../test/data', __FILE__)
    else
      File.expand_path('../data', __FILE__)
    end
  end

  def read_inventories
    pattern = File.join(data_path, "*")
    files = Dir.glob(pattern).map do |path|
      Psych.load_file(path)
    end
    files
  end

  def remove_list(list_id)
    filename = "#{list_id}.yml"
    filepath = get_filepath(filename)
    File.delete(filepath)
  end

  def get_list(list_id)
    read_yaml(list_id)
  end

  def new_list(inventory)
    write_yaml(inventory)
  end

  def add_new_item(list_id, new_item)
    list = get_list(list_id)
    list.add(new_item)
    write_yaml(list)
  end

  def add_qty_to_item(list_id, item_id, obj)
    list = get_list(list_id)
    list.item_id(item_id).add(obj)
    write_yaml(list)
  end

  def use_item(list_id, item_id)
    list = get_list(list_id)
    list.item_id(item_id).use(1)
    write_yaml(list)
  end

  def remove_item(list_id, item_id)
    list = get_list(list_id)
    item_name = list.item_id(item_id).name
    list.remove(item_name)
    write_yaml(list)
  end

  private

  def get_filepath(file)
    File.join(data_path, file)
  end

 def read_yaml(file)
    filename = "#{file}.yml"
    Psych.load_file(get_filepath(filename))
  end

  def write_yaml(inventory)
    filename = "#{inventory.id.to_s}.yml"
    File.write(get_filepath(filename), Psych.dump(inventory))
  end

end
