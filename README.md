# DataTable
[![Build Status](https://secure.travis-ci.org/veracross/data-table.png)](http://travis-ci.org/veracross/data-table)
[![Code Climate](https://codeclimate.com/github/veracross/data-table.png)](https://codeclimate.com/github/veracross/data-table)

DataTable renders collections (an array of hashes or ActiveRecord models) as HTML tables.

## Install
```ruby
gem install data-table
```

or, in your Gemfile

```ruby
gem 'data-table'
```

### Basic Usage

the normal usage is to call the `DataTable.render()` method and pass it a collection.  The method also takes a block which can be used to configure the table.  The column method takes a symbol for the first parameter.  If the symbol matches a key in the @collection, then that value is printed in the cell.

```ruby
DataTable.render(@collection) do |t|
  t.column :column_1, "Title"
  t.column :column_2, "Title 2"
end
```

### Custom Cell Renderer

Sometimes you want to use Ruby code to customize the value for a cell.  This can be done by passing a block to the .column method

```ruby
DataTable.render(@collection) do |t|
   t.column :column_id, "Title" do |value, row, row_index, column, column_index|
     "The value is: #{value}"
   end
end
```

You don't need to pass in all of the block parameters; just the ones up to the one you need.

**Tip** The column_id doesn't need to be an actual key in the collection.  You can just make up an arbitrary column id and use the block renderer to customize the value for a column.


### All Table Configuration Options

    id: the html id
    title: the title of the data table
    subtitle: the subtitle of the data table
    css_class: an extra css class to get applied to the table
    empty_text: the text to display of the collection is empty
    display_header => false: hide the column headers for the data table
    alternate_rows => false: turn off alternating of row css classes
    alternate_cols => true: turn on alternating of column classes, defaults to false

### Totals

It is possible to setup totals & subtotals. Total columns take the name of the column that should be totaled. It is also possible to specify multiple total and subtotal columns.

They also take a default aggregate function name and/or a block.
* If only a default function is given, then it is used to calculate the total
* If only a block is given then only it is used to calculated the total
* If both a block and a function are given then the default aggregate function is called first then its result is passed into the block for further processing.

```ruby
DataTable.render(@collection) do |t|
  t.column :column_1, "Title"
  t.column :column_2, "Title 2"
  t.column :column_3, "Title 3"

  # Use a default function and no block.
  t.total :column_1, :sum, index: 0

  # Pass only a block and an index
  t.total :column_2, nil, index: 1, do |values|
    # custom methods here
  end

  # Pass a default function and a block
  t.total(:column_3, :sum, index: 2) do |aggregate_total|
    format_money(aggregate_total)
  end

end
```

Possible default functions: `:sum`, `:avg`, `:min`, `:max`


### Sub Totals

SubTotals work in a similar way to Totals.  The main difference is that you need to call group_by to specify the different subtotal groupings.

When configuring more than one subtotal column the index parameter is required

```ruby
DataTable.render(@collection) do |t|
  t.column :column_1, "Title"
  t.column :column_2, "Title 2"
  t.column :column_3, "Title 3"
  t.column :column_4, "Title 4"

  t.group_by :column_1

  t.subtotal :column_2, :sum, index: 0
  t.subtotal :column_3, :max, index: 1

end
```
It is possible to use `group_by` on its own without subtotaling.

### Multiple Groups and Sub Totals

It is also possible to combine multiple `group_by` with multiple `subtotal`. In this
scenario you must specify a `level` for each group. When only specifying a single
group you may omit `level`.

```ruby
DataTable.render(@collection) do |t|
  t.column :column_1, "Title"
  t.column :column_2, "Title 2"
  t.column :column_3, "Title 3"

  t.group_by :column_1, level: 0
  t.group_by :column_2, level: 1

  t.subtotal :column_3, :sum
  t.subtotal :column_3, :sum

end
```

You can also combine subtotals & totals in the same table.

## Credits
Nearly all of the code for this was written by @smerickson, and later gemified by @sixfeetover.

## License
Copyright (c) 2012-2013 Jeff Fraser (Veracross LLC) jfraser@breuer.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
