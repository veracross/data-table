module DataTable
  ##
  # Config Options
  #
  # id: the html id
  # title: the title of the data table
  # subtitle: the subtitle of the data table
  # css_class: an extra css class to get applied to the table
  # empty_text: the text to display of the collection is empty
  # display_header => false: hide the column headers for the data table
  # alternate_rows => false: turn off alternating of row css classes
  # alternate_cols => true: turn on alternating of column classes, defaults to false
  #
  # columns: an array of hashes of the column specs for this table
  #
  # group_by: an array of columns to group on
  #
  # subtotals: an array of hashes that contain the subtotal information for each column that should be subtotaled
  # totals: an array of hashes that contain the total information for each column that should be totaled
  #
  ##
  class Table
    attr_reader :collection, :grouped_data, :subtotals, :totals,
                :subtotal_calculations, :total_calculations, :columns

    attr_accessor :id, :title, :css_class, :empty_text,
                  :alternate_rows, :alternate_cols, :display_header, :hide_if_empty,
                  :repeat_headers_for_groups, :custom_headers

    def initialize(collection)
      @collection = collection
      @grouped_collection = nil
      default_options!
      @columns = []
      @groupings = []
      @grouped_data = false
      @subtotals = []
      @totals = []
    end

    def default_options!
      @id = ''
      @title = ''
      @subtitle = ''
      @css_class = ''
      @empty_text = 'No records found'
      @hide_if_empty = false
      @display_header = true
      @alternate_rows = true
      @alternate_cols = false
      @subtotal_title = "Subtotal:"
      @total_title = "Total:"
      @repeat_headers_for_groups = false
      @custom_headers = []
      @row_attributes = nil
    end

    # Define a new column for the table
    def column(id, title = "", opts = {}, &b)
      @columns << DataTable::Column.new(id, title, opts, &b)
    end

    def prepare_data
      group_data! if @grouped_data

      calculate_subtotals! if subtotals?
      calculate_totals! if totals?
    end

    ####################
    # GENERAL RENDERING
    ####################
    def render
      render_data_table
    end

    def render_data_table
      html = "<table id='#{@id}' class='data_table #{@css_class}' cellspacing='0' cellpadding='0'>"
      html << "<caption>#{@title}</caption>" if @title
      html << render_data_table_header if @display_header
      if @collection.any?
        html << render_data_table_body(@collection)
        html << render_totals if totals?
      else
        html << "<tr><td class='empty_data_table' colspan='#{@columns.size}'>#{@empty_text}</td></tr>"
      end
      html << "</table>"
    end

    def render_data_table_header
      html = "<thead>"

      html << render_custom_table_header unless @custom_headers.empty?

      html << "<tr>"
      @columns.each do |col|
        html << col.render_column_header
      end
      html << "</tr></thead>"
    end

    def render_custom_table_header
      html = "<tr class='custom-header'>"
      @custom_headers.each do |h|
        html << "<th class=\"#{h[:css]}\" colspan=\"#{h[:colspan]}\">#{h[:text]}</th>"
      end
      html << "</tr>"
    end

    def render_data_table_body(collection)
      if @grouped_data
        render_grouped_data_table_body(collection)
      else
        "<tbody>#{render_rows(collection)}</tbody>"
      end
    end

    def render_rows(collection)
      html = ""
      collection.each_with_index do |row, row_index|
        css_class = @alternate_rows && row_index % 2 == 1 ? 'alt ' : ''
        if @row_style && style = @row_style.call(row, row_index)
          css_class << style
        end

        attributes = @row_attributes.nil? ? {} : @row_attributes.call(row)
        html << render_row(row, row_index, css_class, attributes)
      end
      html
    end

    def render_row(row, row_index, css_class='', row_attributes={})
      if row_attributes.nil?
        attributes = ''
      else
        attributes = row_attributes.map { |attr, val| "#{attr}='#{val}'" }.join " "
      end

      html = "<tr class='row_#{row_index} #{css_class}' #{attributes}>"
      @columns.each_with_index do |col, col_index|
        cell = row[col.name] rescue nil
        html << col.render_cell(cell, row, row_index, col_index)
      end
      html << "</tr>"
    end

    # define a custom block to be used to determine the css class for a row.
    def row_style(&b)
      @row_style = b
    end

    def custom_header(&blk)
      instance_eval(&blk)
    end

    def th(header_text, options)
      @custom_headers << options.merge(text: header_text)
    end

    def row_attributes(&b)
      @row_attributes = b
    end

    #############
    # GROUPING
    #############

    # TODO: allow for group column only, block only and group column and block
    def group_by(group_column, index = nil, &_blk)
      if index.nil? && @groupings.count >= 1
        raise "an index is required when using multiple groupings."
      end
      @grouped_data = true
      level = {group_column => (index.nil? ? 0 : index.values[0])}
      @groupings << level
      @columns.reject! { |c| c.name == group_column }
    end

    def group_data!
      if @groupings.count > 1
        @collection = collection.group_by_recursive(@groupings)
      else
        @collection = collection.group_by { |row| row[@groupings[0].keys[0]] }
      end
    end

    def render_grouped_data_table_body(collection)
      html = ""
      collection.keys.each do |group_name|
        html << render_group(group_name, collection[group_name])
      end
      html
    end

    def render_group_header(group_header, index = nil)
      css_classes = ["group_header"]
      css_classes << ["level_#{index}"] unless index.nil?
      html =  "<tr class='#{css_classes.join(' ')}'>"
      html << "<th colspan='#{@columns.size}'>#{group_header}</th>"
      html << "</tr>"
      repeat_headers(html) if @repeat_headers_for_groups
      html
    end

    def repeat_headers(html)
      html << "<tr class='col_headers'>"
      @columns.each_with_index do |col, _i|
        html << col.render_column_header
      end
      html << "</tr>"
    end

    def render_group(group_header, group_data)
      # replace non-letters and numbers with '_'
      html = "<tbody class='#{group_header.to_s.downcase.gsub(/[^A-Za-z0-9]+/, '_')}'>"
      html << render_group_header(group_header, 0)
      if group_data.is_a? Array
        html << render_rows(group_data)
        html << render_subtotals(group_header, group_data) if subtotals?
      elsif group_data.is_a? Hash
        html << render_group_recursive(group_data)
      end
      html << "</tbody>"
    end

    def render_group_recursive(collection, index = 1)
      html = ""
      collection.each_pair do |group_header, group_data|
        if group_data.is_a?(Hash)
          html << render_group_header(group_header, index)
          html << render_group_recursive(group_data, index + 1)
        else
          html << render_group_header(group_header, index)
          html << render_rows(group_data)
          html << render_subtotals(group_header, group_data) if subtotals?
        end
      end
      html
    end

    #############
    # TOTALS AND SUBTOTALS
    #############
    def render_totals
      html = "<tfoot>"
      @total_calculations.each_with_index do |totals_row, index|
        html << "<tr class='total index_#{index}'>"
        @columns.each do |col|
          value = totals_row[col.name] ||= nil
          html << col.render_cell(value)
        end
        html << "</tr>"
      end
      html << "</tfoot>"
    end

    def render_subtotals(group_header, _group_data = nil)
      html = ""
      @subtotal_calculations[group_header].each_with_index do |group, index|
        html << "<tr class='subtotal index_#{index}'>"
        @columns.each do |col|
          value = group[col.name] ? group[col.name].values[0] : nil
          html << col.render_cell(value)
        end
        html << "</tr>"
      end
      html
    end

    def subtotal(column_name, function = nil, index = {index: 0}, &b)
      raise "You must supply an index value" if @subtotals.count >= 1 && index.nil?
      total_row @subtotals, column_name, function, index[:index], &b
    end

    def subtotals?
      !@subtotals.empty?
    end

    def total(column_name, function = nil, index = {index: 0}, &block)
      raise "You must supply an index value" if @totals.count >= 1 && index.nil?
      total_row @totals, column_name, function, index[:index], &block
    end

    def totals?
      !@totals.empty?
    end

    # TODO: Refactor to shorten method. Also revise tests.
    def calculate_totals!
      @total_calculations = []
      @totals.compact.each do |total|
        if @collection.is_a?(Hash)
          collection = []
          @collection.each_pair_recursive { |k, v| collection.concat(v) }
        end
        collection = @collection if @collection.is_a? Array
        result = {total.keys.first => calculate(collection, total.keys.first, total.values.first)}
        @total_calculations << result
      end
    end

    def calculate_subtotals!
      # ensure that we are dealing with a grouped results set.
      raise 'Subtotals only work with grouped results sets' unless @grouped_data

      @subtotal_calculations = Hash.new { |h, k| h[k] = [] }
      @collection.each_pair_recursive do |group_name, group_data|
        @subtotals.compact.each_with_index do |subtotal, index|
          result = calculate(group_data, subtotal.first[0], subtotal.first[1])
          subtotal_row = {subtotal.first[0] => {subtotal.first[1] => result}}
          @subtotal_calculations[group_name] << subtotal_row
        end
      end
    end

    # TODO: Write test for this
    def calculate(data, column_name, function)
      column = @columns.select { |column| column.name == column_name }
      if function.is_a?(Proc)
        calculate_with_proc(function, data, column)
      elsif function.is_a?(Array) && function[1].is_a?(Proc)
        calculate_array_and_proc(function, data, column_name)
      elsif function.is_a?(Array)
        calculate_many(function, data, column_name)
      else
        send("calculate_#{function}", data, column_name)
      end
    end

    def calculate_with_proc(function, data, column = nil)
      case function.arity
      when 1 then function.call(data)
      when 2 then function.call(data, column.first)
      end
    end

    def calculate_array_and_proc(function, data, column = nil)
      result = send("calculate_#{function[0]}", data, column)
      case function[1].arity
      when 1 then function[1].call(result)
      when 2 then function[1].call(result, column.first)
      end
    end

    def calculate_many(function, data, column_name)
      function.each do |func|
        if func.is_a? Array
          send("calculate_#{func[0]}", data, column_name)
        else
          send("calculate_#{func}", data, column_name)
        end
      end
    end

    def calculate_sum(collection, column_name)
      collection.inject(0) { |sum, row| sum + row[column_name].to_f }
    end

    def calculate_avg(collection, column_name)
      sum = calculate_sum(collection, column_name)
      sum / collection.size
    end

    def calculate_max(collection, column_name)
      collection.collect { |r| r[column_name].to_f }.max
    end

    def calculate_min(collection, column_name)
      collection.collect { |r| r[column_name].to_f }.min
    end

    private

    # Define a new total column definition.
    # total columns take the name of the column that should be totaled
    # they also take a default aggregate function name and/or a block
    # if only a default function is given, then it is used to calculate the total
    # if only a block is given then only it is used to calculated the total
    # if both a block and a function are given then the default aggregate function is called first
    # then its result is passed into the block for further processing.
    def total_row(collection, column_name, function = nil, index = nil, &block)
      function_or_block = function || block
      f = function && block_given? ? [function, block] : function_or_block
      collection[index] = {column_name => f}
    end
  end
end
