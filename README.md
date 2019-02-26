
This gem is under developement and nowhere near finished but feel free to play around with it.
I am grateful for any ideas and suggestions

# Magentwo
Ruby-Wrapper for the Magento 2 REST API


# How to install
To install the Gem directly use
```
gem install magentwo
```

or add the following line to your Gemfile
```
gem 'magentwo'
```
and call bundler
```
bundle
```


# How to connect to your magento 2 shop
When only using one connection simply type
```
  Magentwo.connect "http://example.com", "user_name", "password"  
```
When using multiple connections at once you can save the result of `Magentwo.connect` and use the `Magentwo.with` method
```
  connection1 = Magentwo.connect "http://example1.com", "user_name", "password"
  connection2 = Magentwo.connect "http://example2.com", "user_name", "password"
  
  Magentwo.with (connection1) do
    #do things in the context of connection1
  end
  Magentwo.with (connection2) do
    #do things in the context of connection2
  end
```

# How to use
In Magentwo you interact with the API using Models. These are named according the the REST-API specifications of Magento 2
The basic functionality is the same for all Models. For products some simple requests would look like this

```
Magentwo::Product.all #fetches all Products
Magentwo::Product.first #fetches the first product
Magentwo::Product.count #returns the number of available products
Magentwo::Product.fields #returns an array of productfields
```

# Filtering
You can filter requests to search for specific elements
Here are some examples

Look for all customers whose firstname is Foobar
```
Magentwo::Customer.filter(:firstname => "Foobar").all
```

Look for all customers whose id is not 42
```
Magentwo::Customer.exclude(:id => 42).all
```

You can also combine these
```
Magentwo::Customer.filter(:firstname => "Foobar").exclude(:id => 42).all
```
The `filter` and `exclude` methods can also be used to filter for a set. To Request all Customers whose firstname is either Foo or Bar you could write
```
Magentwo::Customer.filter(:firstname => ["Foo", "bar"]).all
```

Look for all Products whose name includes the word "Computer"
```
Magentwo::Product.like(:name => "%Computer%").all
```

Compare using `gt`, `gteq`, `lt` or `lteq`. These methods do not seem to work with dates, please use `from` and `to` when e.g. trying to fetch all Products that changed within a certain period.
```
Magentwo::Product.lt(:price => 42).all
Magentwo::Product.gt(:id => 1337).first
```

Compare using `from` and `to`, you may also use both to specify a range.
```
Magentwo::Product.from(:updated_at => Time.new(2019, 1, 1).all
Magentwo::Product.to(:created_at => Time.new(2019, 2, 1).all
```

All of these filter-functions can be chained as needed

# Select
If you know which fields you are interested in you can speed up the fetching process by only requesting these fields
```
Magentwo::Product.filter(...).select(:id, :sku).all
```

# Pagination
On default the pagesize is set to 20, you can change this with
```
Magentwo.default_page_size=42
```

The pagesize can also be set on the fly
To request page 2 with a pagesize of 100 simply write the following. The second paramter is optional
```
Magentwo::Product.exclude(:name => "foobar").page(2, 100).all
```

To iterate threw all the pages use `each_page`. Again the pagesize parameter is optional
```
Magentwo::Product.each_page(512) do |page|
  p page
end
```
You may also want to fetch all pages of products that match a certain criteria
```
Magentwo::Product.from(:updated_at => my_last_sync_value).each_page(512) do |page|
  p page
end
```

# Order
By default the results are ordered as Magento2 "thinks" its best. At any place you may add the `order_by` to sepcify this to your liking. If you skip the `ASC/DESC` argument, `ASC` will be set.
```
Magentwo::Product.order_by(:id, "ASC").all
Magentwo::Product.order_by(:id, "DESC").all
```

# Updates
To update Models back to Magento 2 use the `save` method
This switches the first and last name of the Customer Foo Bar
```
customer = Magentwo::Customer.filter(:first_name => "Foo", :last_name => "Bar").first
customer.firstname = "Bar"
customer.lastname = "Foo"
customer.save
```

to be continued
