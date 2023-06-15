ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'

require_relative '../app.rb'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def create_document(name, content='')
    File.open(File.join(data_path, name), 'w') do |file|
      file.write(content)
    end
  end

  def session
    last_request.env['rack.session']
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def test_index
    create_document('1.yml', "--- !ruby/object:Inventory\nname: T&T\nid: 1")
    create_document('2.yml', "--- !ruby/object:Inventory\nname: Food\nid: 2")

    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'T&amp;T'
    assert_includes last_response.body, 'Food'
    assert_includes last_response.body, 'Add new list'
  end

  def test_add_new_list
    get '/list/add'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Add New List'
    assert_includes last_response.body, 'Name of new list'
    assert_includes last_response.body, "<input type='text'"
    assert_includes last_response.body, "type='submit'"
  end

  def test_post_new_list_ok
    post '/list/add', name: 'my list'
    assert_equal 302, last_response.status
    assert_equal "New list 'my list' added", session[:message]

    get last_response['Location']
    assert_includes last_response.body, 'my list'
  end

  def test_post_new_list_space_name
    post '/list/add', name: ' '
    assert_equal 422, last_response.status

    assert_includes last_response.body, 'List name cannot be blank'
    assert_includes last_response.body, 'Add New List'
    assert_includes last_response.body, 'Name of new list'
    assert_includes last_response.body, "<input type='text'"
    assert_includes last_response.body, "type='submit'"
  end

  def test_post_new_list_repeat_name
    post '/list/add', name: 'my list'
    post '/list/add', name: 'my list'
    assert_equal 422, last_response.status

    assert_includes last_response.body, 'List name must be unique'
    assert_includes last_response.body, 'Add New List'
    assert_includes last_response.body, 'Name of new list'
    assert_includes last_response.body, 'my list'
    assert_includes last_response.body, "<input type='text'"
    assert_includes last_response.body, "type='submit'"
  end

  def test_new_item_form
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory: []\nid: 0")

    get '/list/0/item/add'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Item name'
    assert_includes last_response.body, 'Year'
    assert_includes last_response.body, 'Month'
    assert_includes last_response.body, 'Day'
    assert_includes last_response.body, 'Qty'
    assert_includes last_response.body, "type='submit'"
  end

  def test_post_new_item_ok
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory: []\nid: 0")

    post '/list/0/item/add', name: 'pizza', y: 2023, m: 6, d: 10, qty: 1, list_id: 0
    assert_equal 302, last_response.status
    assert_equal "pizza added", session[:message]

    get last_response['Location']
    assert_includes last_response.body, 'pizza'
  end

  def test_post_new_item_repeat_name
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory: []\nid: 0")

    post '/list/0/item/add', name: 'pizza', y: 2023, m: 6, d: 10, qty: 1, list_id: 0
    
    post '/list/0/item/add', name: 'pizza', y: 2023, m: 6, d: 10, qty: 1, list_id: 0
    assert_equal 422, last_response.status
    assert_includes last_response.body, 'List name must be unique'
    assert_includes last_response.body, 'Item name'
    assert_includes last_response.body, 'pizza'
    assert_includes last_response.body, 'Year'
    assert_includes last_response.body, 'Month'
    assert_includes last_response.body, 'Day'
    assert_includes last_response.body, 'Qty'
    assert_includes last_response.body, "type='submit'"
  end

  def test_post_new_item_repeat_name
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory: []\nid: 0")

    post '/list/0/item/add', name: ' ', y: 2023, m: 6, d: 10, qty: 1, list_id: 0
    assert_equal 422, last_response.status
    assert_includes last_response.body, 'List name cannot be blank'
    assert_includes last_response.body, 'Item name'
    assert_includes last_response.body, 'Year'
    assert_includes last_response.body, 'Month'
    assert_includes last_response.body, 'Day'
    assert_includes last_response.body, 'Qty'
    assert_includes last_response.body, "type='submit'"
  end

  def test_add_item_ok
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory:\n- !ruby/object:Item\n  name: cheese buns\n  inventory:\n  - :date: 2026-02-28\n    :qty: 6\n  id: 0\n- !ruby/object:Item\n  name: pizza\n  inventory: []\n  id: 1\nid: 0")

    post '/list/0/item/1/add', y: 2025, m: 3, d: 20, qty: 4
    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, '4 x pizza added'
    assert_includes last_response.body, 'pizza x 4'
  end

  def test_use_item_ok
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory:\n- !ruby/object:Item\n  name: cheese buns\n  inventory:\n  - :date: 2026-02-28\n    :qty: 6\n  id: 0\n- !ruby/object:Item\n  name: pizza\n  inventory: []\n  id: 1\nid: 0")

    post '/list/0/item/0/use'
    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, "Removed 1 'cheese buns'"
    assert_includes last_response.body, "cheese buns x 5"
  end

  def test_item_detail_ok
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory:\n- !ruby/object:Item\n  name: cheese buns\n  inventory:\n  - :date: 2026-02-28\n    :qty: 6\n  id: 0\n- !ruby/object:Item\n  name: pizza\n  inventory: []\n  id: 1\nid: 0")

    get '/list/0/item/0'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '2026-02-28 x 6'
  end

  def test_remove_from_list_ok
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory:\n- !ruby/object:Item\n  name: cheese buns\n  inventory:\n  - :date: 2026-02-28\n    :qty: 6\n  id: 0\n- !ruby/object:Item\n  name: pizza\n  inventory: []\n  id: 1\nid: 0")
    
    post '/list/0/item/1/remove'
    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, "item 'pizza' removed"
    refute_includes last_response.body, "pizza x 0"
  end
  
  def test_display_list_ok
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory:\n- !ruby/object:Item\n  name: cheese buns\n  inventory:\n  - :date: 2026-02-28\n    :qty: 6\n  id: 0\n- !ruby/object:Item\n  name: pizza\n  inventory: []\n  id: 1\nid: 0")
    post '/list/0/item/add', name: 'bread', y: 2023, m: 6, d: 16, qty: 4, list_id: 1

    get '/list/0'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "food"
    assert_includes last_response.body, "pizza x 0"
    assert_includes last_response.body, "cheese buns x 6"
    assert_includes last_response.body, "bread x 4"
  end

  def test_delete_list_page
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory:\n- !ruby/object:Item\n  name: cheese buns\n  inventory:\n  - :date: 2026-02-28\n    :qty: 6\n  id: 0\n- !ruby/object:Item\n  name: pizza\n  inventory: []\n  id: 1\nid: 0")

    get '/list/0/remove'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Are you sure you want to delete 'food'?"
    assert_includes last_response.body, "All data will be lost - there is no undo"
  end

  def test_remove_specfic_list_ok
    create_document('0.yml', "--- !ruby/object:Inventory\nname: food\ninventory: []\nid: 0")

    post '/list/0/remove'

    get last_response['Location']
    assert_includes last_response.body, "'food' deleted"
  end
end