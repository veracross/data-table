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

  context 'with a more complicated setup' do
    it 'renders okay' do
      raw_results = [
        { 'class' => 'Basketball', 'grade_level' => '9', 'points' => 50 },
        { 'class' => 'Basketball', 'grade_level' => '9', 'points' => 51 },
        { 'class' => 'Basketball', 'grade_level' => '10', 'points' => 52 },
        { 'class' => 'Basketball', 'grade_level' => '10', 'points' => 53 },
        { 'class' => 'Basketball', 'grade_level' => '10', 'points' => 54 },
        { 'class' => 'Basketball', 'grade_level' => '12', 'points' => 55 }
      ]

      fields = [{
        field_name: 'class',
        display_description: 'Class',
        column_width: 1.23,
        data_type: 2
      }, {
        field_name: 'grade_level',
        display_description: 'Grade Level',
        column_width: 2.34,
        data_type: 2
      }, {
        field_name: 'points',
        display_description: 'Points',
        column_width: 3.45,
        data_type: 4
      }]

      column_groups = {}

      subtotal_headers = [
        { field_name: 'class' },
        { field_name: 'grade_level' }
      ]

      subtotal_aggregates = {
        sum: [],
        avg: [{
          field_name: 'points',
          data_type: 4
        }],
        min: [],
        max: []
      }

      total_aggregates = {
        sum: [],
        avg: [],
        min: [],
        max: []
      }

      has_aggregates = true

      raw_results.each_with_index do |record, index|
        record[:___data_table_index___] = index
      end

      html = DataTable.render(raw_results) do |t|
        if has_aggregates
          t.column :__subtotal_header__, '&nbsp;', width: '30px' do |_v|
            '&nbsp;'
          end
        end

        # COLUMN GROUPS
        if column_groups.any?
          t.custom_header do
            th '', colspan: 1, css: 'column-group', style: 'width: 30px;' unless subtotal_headers.empty?

            column_groups.each do |_column_group_index, column_group|
              th column_group[:description], colspan: column_group[:column_count], css: 'column-group', style: "width: #{column_group_width}in;"
            end

            # spacer column
            th '', colspan: 1, css: 'column-group'
          end
        end

        # COLUMNS
        fields.each do |field|
          t.column field[:field_name], field[:display_description], css_class: "data-type-#{field[:data_type]}", width: field[:column_width] do |_v, record|
            record[field[:field_name]]
          end
        end

        # SUBTOTAL HEADERS
        subtotal_headers.each_with_index do |subtotal_header, index|
          t.group_by subtotal_header[:field_name], level: index
        end

        # SUBTOTAL AGGREGATES
        unless subtotal_headers.empty?
          subtotal_aggregates.each_with_index do |(aggregate_function, columns), index|
            next if columns.empty?

            t.subtotal :__subtotal_header__, nil, index do |_records, _column, path|
              "#{path}: #{aggregate_function.to_s.upcase}"
            end

            columns.each do |column|
              t.subtotal column[:field_name], aggregate_function, index do |value|
                value
              end
            end
          end
        end

        # TOTAL AGGREGATES
        total_aggregates.each_with_index do |(aggregate_function, columns), index|
          next if columns.empty?

          t.total :__subtotal_header__, nil, index do |_records|
            aggregate_function.to_s.upcase
          end

          columns.each do |column|
            t.total column[:field_name], aggregate_function, index do |value|
              value
            end
          end
        end

        # spacer column
        t.column :_empty_space, ''
      end

      expected_html = %(<table id='' class='data_table ' cellspacing='0' cellpadding='0'><caption></caption><thead><tr><th class='__subtotal_header__ ' style='width: 30px'>&nbsp;</th><th class='points  data-type-4' style='width: 3.45'>Points</th><th class='_empty_space ' ></th></tr></thead><tbody class='basketball'><tr class='group_header level_0'><th colspan='3'>Basketball</th></tr><tr class='group_header level_1'><th colspan='3'>9</th></tr><tr class='row_0 ' ><td class='__subtotal_header__ nilclass' >&nbsp;</td><td class='points numeric data-type-4' >50</td><td class='_empty_space nilclass' ></td></tr><tr class='row_1 alt ' ><td class='__subtotal_header__ nilclass' >&nbsp;</td><td class='points numeric data-type-4' >51</td><td class='_empty_space nilclass' ></td></tr><tr class='subtotal index_1 first'><td class='__subtotal_header__ nilclass' >9: AVG</td><td class='points numeric data-type-4' >50.5</td><td class='_empty_space nilclass' ></td></tr><tr class='group_header level_1'><th colspan='3'>10</th></tr><tr class='row_0 ' ><td class='__subtotal_header__ nilclass' >&nbsp;</td><td class='points numeric data-type-4' >52</td><td class='_empty_space nilclass' ></td></tr><tr class='row_1 alt ' ><td class='__subtotal_header__ nilclass' >&nbsp;</td><td class='points numeric data-type-4' >53</td><td class='_empty_space nilclass' ></td></tr><tr class='row_2 ' ><td class='__subtotal_header__ nilclass' >&nbsp;</td><td class='points numeric data-type-4' >54</td><td class='_empty_space nilclass' ></td></tr><tr class='subtotal index_1 first'><td class='__subtotal_header__ nilclass' >10: AVG</td><td class='points numeric data-type-4' >53.0</td><td class='_empty_space nilclass' ></td></tr><tr class='group_header level_1'><th colspan='3'>12</th></tr><tr class='row_0 ' ><td class='__subtotal_header__ nilclass' >&nbsp;</td><td class='points numeric data-type-4' >55</td><td class='_empty_space nilclass' ></td></tr><tr class='subtotal index_1 first'><td class='__subtotal_header__ nilclass' >12: AVG</td><td class='points numeric data-type-4' >55.0</td><td class='_empty_space nilclass' ></td></tr><tr class='parent_subtotal index_1 basketball'><td class='__subtotal_header__ nilclass' >Basketball: AVG</td><td class='points numeric data-type-4' >52.5</td><td class='_empty_space nilclass' ></td></tr></tbody></table>)
      expect(html).to eq(expected_html)
    end
  end
end
