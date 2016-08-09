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
    #############
    # CONFIG
    #############
    attr_reader :collection, :grouped_data, :subtotals, :totals, :subtotal_calculations, :total_calculations, :columns
    attr_accessor :id, :title, :css_class, :empty_text, :alternate_rows, :alternate_cols, :display_header, :hide_if_empty, :repeat_headers_for_groups, :custom_headers

    def initialize(collection)
      @collection = collection
      @grouped_collection = nil
      default_options!
      @columns = []
      @groupings = []
      @grouped_data = false
      @subtotals = {}
      @totals = {}
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
        if @row_style && style == @row_style.call(row, row_index)
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
        attributes = row_attributes.map {|attr, val| "#{attr}='#{val}'"}.join " "
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
    def group_by(group_column, group_level, &_blk)
      @grouped_data = true
      @groupings << { group_column => group_level.values[0] }
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

    def render_group_header(group_header, group_level = nil)
      css_classes = ["group_header"]
      css_classes << ["level_#{group_level}"] unless group_level.nil?
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
      html << render_group_recursive(group_data)
      html << render_subtotals(group_header, group_data) if subtotals? && !group_data.is_a?(Hash)
      html << "</tbody>"
    end

    def render_group_recursive(collection)
      html = ""
      collection.each_pair do |key, val|
        if val.is_a?(Hash)
          html ||= render_group_header(key)
          render_group_recursive(val)
        else
          html << render_group_header(key)
          html << render_rows(val)
        end
      end
      html
    end

    #############
    # TOTALS AND SUBTOTALS
    #############
    def render_totals
      html = "<tfoot><tr>"
      @columns.each do |col|
        html << col.render_cell(@total_calculations[col.name])
      end
      html << "</tr></tfoot>"
    end

    def render_subtotals(group_header, _group_data)
      html = "<tr class='subtotal'>"
      @columns.each do |col|
        html << col.render_cell(@subtotal_calculations[group_header][col.name])
      end
      html << "</tr>"
    end

    def subtotal(column_name, function = nil, &b)
      total_row @subtotals, column_name, function, &b
    end

    def subtotals?
      !@subtotals.empty?
    end

    def total(column_name, function = nil, &b)
      total_row @totals, column_name, function, &b
    end

    def totals?
      !@totals.empty?
    end

    def calculate_totals!
      @total_calculations = {}

      @totals.each do |column_name, function|
        collection = []
        if @collection.is_a?(Hash)
          @collection.each_pair_recursive {|k, v| collection.concat(v) }
        else
          collection = @collection
        end
        result = calculate(collection, column_name, function)
        @total_calculations[column_name] = result
      end
    end

    def calculate_subtotals!
      @subtotal_calculations = Hash.new { |h, k| h[k] = {} }

      # ensure that we are dealing with a grouped results set.
      raise 'Subtotals only work with grouped results sets' unless @grouped_data

      @collection.each_pair_recursive do |group_name, group_data|
        @subtotals.each do |column_name, function|
          result = calculate(group_data, column_name, function)
          @subtotal_calculations[group_name][column_name] = result
        end
      end
    end

    def calculate(data, column_name, function)
      col = @columns.select { |column| column.name == column_name }
      if function.is_a?(Proc)
        case function.arity
        when 1 then function.call(data)
        when 2 then function.call(data, col.first)
        end
      elsif function.is_a?(Array)
        result = send("calculate_#{function[0]}", data, column_name)
        case function[1].arity
        when 1 then function[1].call(result)
        when 2 then function[1].call(result, col.first)
        end
      else
        send("calculate_#{function}", data, column_name)
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
    def total_row(collection, column_name, function = nil, &b)
      function_or_block = function || b
      f = function && block_given? ? [function, b] : function_or_block
      collection.merge!(column_name => f)
    end
  end
end
