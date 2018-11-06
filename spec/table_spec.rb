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
      expect(data_table.columns).to_not be_empty
      expect(data_table.columns.first.class).to be(DataTable::Column)
    end

    it "should render the collection" do
      data_table.column(:name, 'Name')
      data_table.column(:class, 'Class')
      expect(data_table.render).to \
        eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr><th class='name ' >Name</th><th class='class ' >Class</th></tr></thead><tbody><tr class='row_0 ' ><td class='name text' >Luke Skywalker</td><td class='class text' >Jedi Knight</td></tr><tr class='row_1 alt ' ><td class='name text' >Emporer Palpatine</td><td class='class text' >Sith Lord</td></tr><tr class='row_2 ' ><td class='name text' >Mithrander</td><td class='class text' >Wizard</td></tr><tr class='row_3 alt ' ><td class='name text' >Aragorn</td><td class='class text' >Ranger</td></tr></tbody></table>})
    end

    it "should group the records" do
      grouping_column = :world

      data_table.group_by grouping_column, level: 0
      data_table.column(:name, 'Name')
      data_table.column(:class, 'Class')
      expect(data_table.grouped_data).to be true
      data_table.prepare_data
      expect(data_table.collection).to eq(collection.group_by {|g| g[grouping_column]})
      expect(data_table.render).to eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr><th class='name ' >Name</th><th class='class ' >Class</th></tr></thead><tbody class='star_wars'><tr class='group_header level_0'><th colspan='2'>Star Wars</th></tr><tr class='row_0 ' ><td class='name text' >Luke Skywalker</td><td class='class text' >Jedi Knight</td></tr><tr class='row_1 alt ' ><td class='name text' >Emporer Palpatine</td><td class='class text' >Sith Lord</td></tr></tbody><tbody class='middle_earth'><tr class='group_header level_0'><th colspan='2'>Middle Earth</th></tr><tr class='row_0 ' ><td class='name text' >Mithrander</td><td class='class text' >Wizard</td></tr><tr class='row_1 alt ' ><td class='name text' >Aragorn</td><td class='class text' >Ranger</td></tr></tbody></table>})
    end

    it "should do totaling" do
      data_table.column :power_level
      data_table.total :power_level, :sum, 0
      data_table.calculate_totals!
      expect(data_table.total_calculations).to eq([{:power_level=>9226.0}])
    end

    it "should do custom formatting for the total" do
      data_table.column :power_level
      data_table.total :power_level, :avg, 0 do |average|
        "#{average / 100.0}%"
      end
      data_table.calculate_totals!
      expect(data_table.total_calculations).to eq([{:power_level=>"23.065%"}])
    end

    it "should do custom totalling" do
      data_table.column :power_level
      data_table.total :power_level do |collection|
        collection.inject(0) { |sum, c| sum + c[:power_level] }
      end
      data_table.calculate_totals!
      expect(data_table.total_calculations).to eq([{:power_level=>9226}])
    end

    it "should do sub-totaling" do
      data_table.group_by :world, level: 0
      data_table.column :power_level
      data_table.subtotal :power_level, :sum, 0

      data_table.prepare_data
      expect(data_table.subtotal_calculations).to eq({["Star Wars"]=>[{:power_level=>{:sum=>145.0}}], ["Middle Earth"]=>[{:power_level=>{:sum=>9081.0}}]})
    end

    it "should do sub-totaling starting with indexes > 0" do
      data_table.group_by :world, level: 0
      data_table.column :power_level
      data_table.subtotal :power_level, :sum, 1

      data_table.prepare_data

      expect(data_table.subtotal_calculations).to eq({
        ["Star Wars"] => [{}, {:power_level => {:sum => 145.0}}],
        ["Middle Earth"] => [{}, {:power_level => {:sum => 9081.0}}]
      })
    end

    it "should not render empty sub-total aggregate rows" do
      data_table.group_by :world, level: 0
      data_table.column :power_level
      data_table.subtotal :power_level, nil, 1 do |_records, _column, path|
        path
      end

      data_table.prepare_data
      subtotal_calculations = data_table.subtotal_calculations

      # this is convoluted because it's hard to assert a nested structure that includes procs
      # [
      #   ["Middle Earth"] => [{}, {:power_level=>{#<Proc:0x03dbead8@table_spec.rb:78>=>"Middle Earth"}}],
      #   ["Star Wars"] => [{}, {:power_level=>{#<Proc:0x03dbead8@table_spec.rb:78>=>"Star Wars"}}]
      # ]
      expect(subtotal_calculations.keys).to eq([["Star Wars"], ["Middle Earth"]])
      expect(subtotal_calculations.values.flatten.map(&:keys)).to eq([[], [:power_level], [], [:power_level]])
      subtotal_calculations.values.flatten.map(&:values).flatten.map(&:keys).each do |k|
        expect(k).to be_a(Array)
        expect(k.length).to eq(1)
        expect(k[0]).to be_a(Proc)
      end
      expect(subtotal_calculations.values.flatten.map(&:values).flatten.map(&:values)).to eq([["Star Wars"], ["Middle Earth"]])

      # note how the rows are index_1, and there is no index_0 row
      expect(data_table.render).to \
      eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr><th class='power_level ' ></th></tr></thead><tbody class='star_wars'><tr class='group_header level_0'><th colspan='1'>Star Wars</th></tr><tr class='row_0 ' ><td class='power_level numeric' >50</td></tr><tr class='row_1 alt ' ><td class='power_level numeric' >95</td></tr><tr class='subtotal index_1 first'><td class='power_level numeric' >Star Wars</td></tr></tbody><tbody class='middle_earth'><tr class='group_header level_0'><th colspan='1'>Middle Earth</th></tr><tr class='row_0 ' ><td class='power_level numeric' >9001</td></tr><tr class='row_1 alt ' ><td class='power_level numeric' >80</td></tr><tr class='subtotal index_1 first'><td class='power_level numeric' >Middle Earth</td></tr></tbody></table>})
    end

    it "should render a custom header" do
      data_table.custom_header do
        th 'Two Columns', :colspan => 2
        th 'One Column', :colspan => 1
      end
      expect(data_table.render_custom_table_header).to eq(%{<tr class='custom-header'><th class="" colspan="2" style="">Two Columns</th><th class="" colspan="1" style="">One Column</th></tr>})
    end
  end

	context "with an empty collection" do
    let(:collection) {Array.new}
    let(:data_table) {DataTable::Table.new(collection)}

    it "should render a table with the 'no records' message" do
      expect(data_table.render).to \
        eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr></tr></thead><tr><td class='empty_data_table' colspan='0'>No records found</td></tr></table>})
    end

    it "should render a custom empty text notice" do
      text = "Nothing to see here"
      data_table.empty_text = text
      expect(data_table.render).to \
      eq(%{<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr></tr></thead><tr><td class='empty_data_table' colspan='0'>#{text}</td></tr></table>})
    end
  end
end
