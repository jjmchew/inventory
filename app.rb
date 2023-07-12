require 'sinatra'
require 'tilt/erubis'
require 'date'

require_relative 'item'
require_relative 'inventory'
require_relative 'date'
require_relative 'persist_yml'

MODE = 'DEV'
BASE_URL = MODE == 'DEV' ? '' : '/inventory'

include DateHelper

module MiscHelpers
  def max_id
    lists = @storage.read_inventories
    max = 0
    lists.each do |list|
      max = list.id if list.id > max
    end
    max + 1
  end
end
include MiscHelpers

module ValidationHelpers
  def list_name_validation(name)
    msg = []
    msg << "List name cannot be blank" if name.strip.empty?
    msg << "List name must be unique" if @storage.read_inventories.any? { |list| list.name == name.strip }
    msg
  end

  def item_name_validation(list, item_name)
    msg = []
    msg << "List name cannot be blank" if item_name.strip.empty?
    list.each do |item|
      if item.name == item_name
        msg << "List name must be unique"
        break
      end
    end
    msg
  end
end
include ValidationHelpers

configure do
  enable :sessions
  set :session_secret, 'this/is/secret!'
  set :erb, escape_html: true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'persist_yml.rb'
end

helpers do
  def list
    @list ||= @storage.get_list(params[:list_id]) || halt(404)
  end

  def item
    @item ||= list.item_id(params[:item_id].to_i) || halt(404)
  end

  def item_class(item)
    return "expiry_near" if highlight_date?(item)
  end
end

before do
  @storage = PersistYML.new(ENV)
end

# Index route - list of lists
get '/' do
  @lists = @storage.read_inventories
  erb :index
end

# Display "add new list" form
get '/list/add' do
  erb :new_list
end

# Add an entirely new list
post '/list/add' do
  msg = list_name_validation(params[:name])

  if msg.empty?
    new_list = Inventory.new(params[:name])
    new_list.set_id(max_id)
    @storage.new_list(new_list)

    session[:message] = "New list '#{params[:name]}' added"
    redirect url('/')
  else
    status 422
    session[:message] = msg.join(', ')
    erb :new_list
  end
end

# display new_item form
get '/list/:list_id/item/add' do
  erb :new_item
end

# add new item to list
post '/list/:list_id/item/add' do
  msg = item_name_validation(list, params[:name])

  if msg.empty?
    new_item = Item.new(params[:name], {
      date: Date.new(params[:y].to_i, params[:m].to_i, params[:d].to_i),
      qty: params[:qty].to_i
    })
    new_list = list.add(new_item)
    new_item.set_id(list.size - 1)

    @storage.add_new_item(params[:list_id].to_i, new_item)

    session[:message] = "#{params[:name]} added"
    redirect url("/list/#{params[:list_id]}")
  else
    status 422
    session[:message] = msg.join(', ')
    erb :new_item
  end
end

# display add_item form (date, qty)
get '/list/:list_id/item/:item_id/add' do
  @item = item
  erb :add_item
end

# display item detail (list of date x qty)
get '/list/:list_id/item/:item_id' do
  @item = item
  erb :item_detail
end

# add qty to existing item
post '/list/:list_id/item/:item_id/add' do
  date = Date.new(params[:y].to_i, params[:m].to_i, params[:d].to_i)
  obj = { date: date, qty: params[:qty].to_i }
  @storage.add_qty_to_item(params[:list_id].to_i, params[:item_id].to_i, obj)

  session[:message] = "#{params[:qty].to_i} x #{item.name} added"
  redirect url("/list/#{params[:list_id]}")
end

# uses 1 of the item
post '/list/:list_id/item/:item_id/use' do
  @storage.use_item(params[:list_id].to_i, params[:item_id].to_i)
  session[:message] = "Removed 1 '#{item.name}'"
  redirect url("/list/#{params[:list_id]}")
end

# remove item from list
post '/list/:list_id/item/:item_id/remove' do
  item_name = item.name

  @storage.remove_item(params[:list_id].to_i, params[:item_id].to_i)
  session[:message] = "item '#{item_name}' removed"
  redirect url("/list/#{params[:list_id]}")
end

# display a specific list
get '/list/:list_id' do
  @list = list
  erb :list
end

# display delete_list page
get '/list/:list_id/remove' do
  @list = list
  erb :delete_list
end

# remove a specific list
post '/list/:list_id/remove' do
  list_name = list.name
  @storage.remove_list(params[:list_id])
  session[:message] = "'#{list_name}' deleted"
  redirect url('/')
end

