
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
Currently there is only one connection at a time possible
```
  Magentwo.connect http://example.com, username, password  
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
