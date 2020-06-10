require 'csv'

# Merchant seeds
MERCHANT_FILE = Rails.root.join('db', 'seed_data', 'merchants.csv')
puts "Loading raw product data from #{MERCHANT_FILE}"

merchant_failures = []
CSV.foreach(MERCHANT_FILE, :headers => true) do |row|
  merchant = Merchant.new
  merchant.id = row['id']
  merchant.email = row['email']
  merchant.username = row['username']
  p row['username']
  
  p merchant
  successful = merchant.save
  if !successful
    merchant_failures << merchant
  end
end

puts "Added #{Merchant.count} merchant records"
puts "#{merchant_failures.length} merchants failed to save"

# Product seeds
PRODUCT_FILE = Rails.root.join('db', 'seed_data', 'products.csv')
puts "Loading raw product data from #{PRODUCT_FILE}"

product_failures = []
CSV.foreach(PRODUCT_FILE, :headers => true) do |row|
  product = Product.new
  product.id = row['id']
  product.name = row['name']
  product.description = row['description']
  product.photo = row['photo']
  product.stock = row['stock']
  product.active = row['active']
  product.price = row['price']
  product.merchant_id = row['merchant_id']

  successful = product.save
  if !successful
    product_failures << product
  end
end

puts "Added #{Product.count} product records"
puts "#{product_failures.length} products failed to save"

# Order seeds
ORDER_FILE = Rails.root.join('db', 'seed_data', 'orders.csv')
puts "Loading raw order data from #{ORDER_FILE}"

order_failures = []
CSV.foreach(ORDER_FILE, :headers => true) do |row|
  order = Order.new
  order.id = row['id']
  order.status = row['status']
  order.credit_card_num = row['credit_card_num']
  order.credit_card_exp = row['credit_card_exp']
  order.credit_card_cvv = row['credit_card_cvv']
  order.address = row['address']
  order.city = row['city']
  order.state = row['state']
  order.zip = row['zip']
  order.time_submitted = row['time_submitted']
  order.customer_email = row['customer_email']

  successful = order.save
  if !successful
    order_failures << order
  end
end

puts "Added #{Order.count} order records"
puts "#{order_failures.length} orders failed to save"

# reloading postgres for the latest ID
puts "Manually resetting PK sequence on each table"
ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

puts "done"