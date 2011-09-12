# DataTable

## Install
```ruby
gem install data-table
```

or, in your Gemfile
```ruby
gem 'data-table'
```

## Synopsis
```ruby
records = [{:name => 'Matz', :language => 'Ruby'}, {:name => 'Ashkenas', :language => 'CoffeeScript'}, {:name => 'Guido', :language => 'Python'}]

DataTable.render(records) do |t|
  t.id = 'language-table'
  t.cssClass = 'table'
  
  t.column :name, 'Creator Name'
  t.column :language, 'Language'
end
```