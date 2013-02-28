require 'spec_helper'

describe DataTable::Table do
  context "with a non-empty collection of hashes" do
    let(:collection) {
      [
        {:name => 'Luke Skywalker', :class => 'Jedi Knight', :world => 'Star Wars', :power_level => 50},
        {:name => 'Emporer Palpatine', :class => 'Sith Lord', :world => 'Star Wars', :power_level => 95},
        {:name => 'Mithrander', :class => 'Wizard', :world => 'Middle Earth', :power_level => 9001},
        {:name => 'Aragorn', :class => 'Ranger', :world => 'Middle Earth', :power_level => 80}
      ]
    }

    let(:data_table) {DataTable::Table.new(collection)}

    it "should add a column do @columns" do
      data_table.column(:name, 'Name')
      data_table.columns.should_not be_empty
      data_table.columns.first.class.should be(DataTable::Column)
    end

    it "should render the collection" do
      data_table.column(:name, 'Name')
      data_table.column(:class, 'Class')
      data_table.render.should \
        eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr><th class='name ' >Name</th><th class='class ' >Class</th></tr></thead><tbody><tr class='row_0 ' ><td class='name text' >Luke Skywalker</td><td class='class text' >Jedi Knight</td></tr><tr class='row_1 alt ' ><td class='name text' >Emporer Palpatine</td><td class='class text' >Sith Lord</td></tr><tr class='row_2 ' ><td class='name text' >Mithrander</td><td class='class text' >Wizard</td></tr><tr class='row_3 alt ' ><td class='name text' >Aragorn</td><td class='class text' >Ranger</td></tr></tbody></table>})
    end

    it "should group the records" do
      grouping_column = :world

      data_table.group_by grouping_column
      data_table.column(:name, 'Name')
      data_table.column(:class, 'Class')
      data_table.grouped_data.should be_true
      data_table.prepare_data
      data_table.collection.should eq(collection.group_by {|g| g[grouping_column]})
      data_table.render.should eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr><th class='name ' >Name</th><th class='class ' >Class</th></tr></thead><tbody class='star_wars'><tr class='group_header'><th colspan='2'>Star Wars</th></tr><tr class='row_0 ' ><td class='name text' >Luke Skywalker</td><td class='class text' >Jedi Knight</td></tr><tr class='row_1 alt ' ><td class='name text' >Emporer Palpatine</td><td class='class text' >Sith Lord</td></tr></tbody><tbody class='middle_earth'><tr class='group_header'><th colspan='2'>Middle Earth</th></tr><tr class='row_0 ' ><td class='name text' >Mithrander</td><td class='class text' >Wizard</td></tr><tr class='row_1 alt ' ><td class='name text' >Aragorn</td><td class='class text' >Ranger</td></tr></tbody></table>})
    end

    it "should do totaling" do
      data_table.column :power_level
      data_table.total :power_level, :sum
      data_table.calculate_totals!
      data_table.total_calculations.should eq({:power_level => 9226.0})
    end

    it "should do custom formatting for the total" do
      data_table.column :power_level
      data_table.total :power_level, :avg do |average|
        "#{average / 100.0}%"
      end
      data_table.calculate_totals!
      data_table.total_calculations.should eq({:power_level => "23.065%"})
    end

    it "should do custom totalling" do
      data_table.column :power_level
      data_table.total :power_level do |collection|
        collection.inject(0) {|sum, c| sum + c[:power_level] }
      end
      data_table.calculate_totals!
      data_table.total_calculations.should eq({:power_level => 9226.0})
    end

    it "should do sub-totaling" do
      data_table.group_by :world
      data_table.column :power_level
      data_table.subtotal :power_level, :sum

      data_table.prepare_data
      data_table.subtotal_calculations.should eq({"Star Wars" => {:power_level => 145.0}, "Middle Earth" => {:power_level => 9081.0}})
    end

    it "should render a custom header" do
      data_table.custom_header do
        th 'Two Columns', :colspan => 2
        th 'One Column', :colspan => 1
      end
      data_table.render_custom_table_header.should eq(%{<tr class='custom-header'><th class="" colspan="2">Two Columns</th><th class="" colspan="1">One Column</th></tr>})
    end
  end

	context "with an empty collection" do
    let(:collection) {Array.new}
    let(:data_table) {DataTable::Table.new(collection)}

    it "should render a table with the 'no records' message" do
      data_table.render.should \
        eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr></tr></thead><tr><td class='empty_data_table' colspan='0'>No records found</td></tr></table>})
    end

    it "should render a custom empty text notice" do
      text = "Nothing to see here"
      data_table.empty_text = text
      data_table.render.should \
      eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr></tr></thead><tr><td class='empty_data_table' colspan='0'>#{text}</td></tr></table>})
    end
  end
end
