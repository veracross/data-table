require 'spec_helper'

describe DataTable::Column do
  it "should store the name" do
    column = DataTable::Column.new(:thing)
    expect(column.name).to eq(:thing)
  end

  it "should add the column name as a css class" do
    column = DataTable::Column.new(:thing)
    expect(column.css_class_names).to include('thing')
  end

  it "should render a td tag" do
    column = DataTable::Column.new(:thing)
    expect(column.render_cell("Data")).to eq(%(<td class='thing text' >Data</td>))
  end

  it "should render the column header" do
    column = DataTable::Column.new(:thing, 'Thing')
    expect(column.render_column_header).to eq(%(<th class='thing ' >Thing</th>))
  end

  it "should add custom attributes to the td tag" do
    options = {
      attributes: {
        'data-type' => 'text',
        'data-id' => 1
      }
    }
    column = DataTable::Column.new(:thing, 'Thing', options)
    expect(column.custom_attributes).to eq("data-type='text' data-id='1'")
    expect(column.render_cell('Data')).to  include("data-type='text'")
  end

  it "should use the block for rendering" do
    square = lambda { |v| v.to_i ** 2 }
    column = DataTable::Column.new(:amount, 'Amount', &square)
    expect(column.render_cell(5, amount: 5)).to eq(%(<td class='amount numeric' >25</td>))
  end
end
