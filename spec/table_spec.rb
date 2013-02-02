require 'spec_helper'

describe DataTable::Table do
  context "with a non-empty collection of hashes" do
    let(:collection) {
      [
        {:name => 'Luke Skywalker', :class => 'Jedi Knight', :world => 'Star Wars'},
        {:name => 'Emporer Palpatine', :class => 'Sith Lord', :world => 'Star Wars'},
        {:name => 'Mithrander', :class => 'Wizard', :world => 'Middle Earth'},
        {:name => 'Aragorn', :class => 'Ranger', :world => 'Middle Earth'}
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
        eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr><th class='name text' >Name</th><th class='class text' >Class</th></tr></thead><tbody><tr class='row_0 ' ><td class='name text' >Luke Skywalker</td><td class='class text' >Jedi Knight</td></tr><tr class='row_1 alt ' ><td class='name text' >Emporer Palpatine</td><td class='class text' >Sith Lord</td></tr><tr class='row_2 ' ><td class='name text' >Mithrander</td><td class='class text' >Wizard</td></tr><tr class='row_3 alt ' ><td class='name text' >Aragorn</td><td class='class text' >Ranger</td></tr></tbody></table>})
    end

    it "should group the records" do
      grouping_column = :world

      data_table.group_by grouping_column
      data_table.column(:name, 'Name')
      data_table.column(:class, 'Class')
      data_table.grouped_data.should be_true
      data_table.prepare_data
      data_table.collection.should eq(collection.group_by {|g| g[grouping_column]})
      data_table.render.should eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr><th class='name text' >Name</th><th class='class text' >Class</th></tr></thead><tbody class='star_wars'><tr class='group_header'><th colspan='2'>Star Wars</th></tr><tr class='row_0 ' ><td class='name text' >Luke Skywalker</td><td class='class text' >Jedi Knight</td></tr><tr class='row_1 alt ' ><td class='name text' >Emporer Palpatine</td><td class='class text' >Sith Lord</td></tr></tbody><tbody class='middle_earth'><tr class='group_header'><th colspan='2'>Middle Earth</th></tr><tr class='row_0 ' ><td class='name text' >Mithrander</td><td class='class text' >Wizard</td></tr><tr class='row_1 alt ' ><td class='name text' >Aragorn</td><td class='class text' >Ranger</td></tr></tbody></table>})
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