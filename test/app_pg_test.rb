ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../app.rb'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def session
    last_request.env['rack.session']
  end

  def test_index
    skip
    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Food'
    assert_includes last_response.body, 'Stuff'
    assert_includes last_response.body, 'Add new list'
  end

  def test_add_new_list
    skip
    get '/list/add'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Add New List'
    assert_includes last_response.body, 'Name of new list'
    assert_includes last_response.body, "<input type='text'"
    assert_includes last_response.body, "type='submit'"
  end

  def test_post_new_list_ok
    skip
    post '/list/add', name: 'my list'
    assert_equal 302, last_response.status
    assert_equal "New list 'my list' added", session[:message]

    get last_response['Location']
    assert_includes last_response.body, 'my list'
  end

  def test_post_new_list_space_name
    skip
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
    get '/'
    puts last_response.body
    
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
    skip
    get '/list/1/item/add'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Item name'
    assert_includes last_response.body, 'Year'
    assert_includes last_response.body, 'Month'
    assert_includes last_response.body, 'Day'
    assert_includes last_response.body, 'Qty'
    assert_includes last_response.body, "type='submit'"
  end

  def test_post_new_item_ok
    skip
    post '/list/1/item/add', name: 'pizza', y: 2023, m: 6, d: 10, qty: 1, list_id: 0
    assert_equal 302, last_response.status
    assert_equal "pizza added", session[:message]

    get last_response['Location']
    assert_includes last_response.body, 'pizza'
  end

  # def test_post_new_item_repeat_name
  #   post '/list/1/item/add', name: 'pizza', y: 2023, m: 6, d: 10, qty: 1, list_id: 0
    
  #   post '/list/1/item/add', name: 'pizza', y: 2023, m: 6, d: 10, qty: 1, list_id: 0
  #   assert_equal 422, last_response.status
  #   assert_includes last_response.body, 'List name must be unique'
  #   assert_includes last_response.body, 'Item name'
  #   assert_includes last_response.body, 'pizza'
  #   assert_includes last_response.body, 'Year'
  #   assert_includes last_response.body, 'Month'
  #   assert_includes last_response.body, 'Day'
  #   assert_includes last_response.body, 'Qty'
  #   assert_includes last_response.body, "type='submit'"
  # end

  def test_post_new_item_blank_name
    skip
    post '/list/1/item/add', name: ' ', y: 2023, m: 6, d: 10, qty: 1, list_id: 0
    assert_equal 422, last_response.status
    assert_includes last_response.body, 'List name cannot be blank'
    assert_includes last_response.body, 'Item name'
    assert_includes last_response.body, 'Year'
    assert_includes last_response.body, 'Month'
    assert_includes last_response.body, 'Day'
    assert_includes last_response.body, 'Qty'
    assert_includes last_response.body, "type='submit'"
  end

  # def test_add_item_ok
  #   post '/list/1/item/1/add', y: 2025, m: 3, d: 20, qty: 4
  #   assert_equal 302, last_response.status

  #   get last_response['Location']
  #   assert_includes last_response.body, '4 x pasta sauce added'
  #   assert_includes last_response.body, 'pasta sauce x 10'
  # end

  # def test_use_item_ok
  #   post '/list/1/item/1/use'
  #   assert_equal 302, last_response.status

  #   get last_response['Location']
  #   assert_includes last_response.body, "Removed 1 'pasta sauce'"
  #   assert_includes last_response.body, "pasta sauce x 5"
  # end

  def test_item_detail_ok
    skip
    get '/list/1/item/1'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '2025-09-04 x 2'
    assert_includes last_response.body, '2025-12-20 x 4'
  end

  def test_remove_from_list_ok
    skip
    post '/list/1/item/1/remove'
    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, "item 'pasta sauce' removed"
    refute_includes last_response.body, "pasta sauce x 0"
  end
  
  # def test_display_list_ok
  #   post '/list/1/item/add', name: 'bread', y: 2023, m: 6, d: 16, qty: 4, list_id: 1

  #   get '/list/1'
  #   assert_equal 200, last_response.status
  #   assert_includes last_response.body, "Food"
  #   assert_includes last_response.body, "pasta sauce x 6"
  #   assert_includes last_response.body, "chips x 2"
  #   assert_includes last_response.body, "bread x 4"
  # end

  def test_delete_list_page
    skip
    get '/list/1/remove'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Are you sure you want to delete 'Food'?"
    assert_includes last_response.body, "All data will be lost - there is no undo"
  end

  def test_remove_specfic_list_ok
    skip
    post '/list/1/remove'

    get last_response['Location']
    assert_includes last_response.body, "'Food' deleted"
  end
end
