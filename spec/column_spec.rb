require 'spec_helper'

describe DataTable::Column do
  it "should store the name" do
    column = DataTable::Column.new(:thing)
    column.name.should eq(:thing)
  end

  it "should add the column name as a css class" do
    column = DataTable::Column.new(:thing)
    column.css_class_names.should =~ /thing/
  end

  it "should render a td tag" do
    column = DataTable::Column.new(:thing)
    column.render_cell("Data").
      should eq(%{<td class='thing text' >Data</td>})
  end

  it "should render the column header" do
    column = DataTable::Column.new(:thing, 'Thing')
    column.render_column_header
    .should eq(%{<th class='thing text' >Thing</th>})
  end

  it "should add custom attributes to the td tag" do
    options = {
      :attributes => {
        'data-type' => 'text',
        'data-id' => 1
      }
    }
    column = DataTable::Column.new(:thing, 'Thing', options)
    column.custom_attributes.should eq("data-type='text' data-id='1'")
    column.render_cell('Data').should =~ /data-type='text'/
  end

  it "should use the block for rendering" do
    square = lambda {|v| v.to_i ** 2}
    column = DataTable::Column.new(:amount, 'Amount', &square)
    column.render_cell(5, {:amount => 5}).should eq(%{<td class='amount text' >25</td>})
  end
end
