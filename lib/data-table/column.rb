# frozen_string_literal: true
module DataTable
  class Column
    attr_reader :name
    attr_accessor :display, :index, :options, :css_class, :attributes

    def initialize(name, description = '', opts = {}, &renderer)
      @name = name
      @description = description
      @data_type = opts[:data_type]
      @help_text = opts[:help_text]
      @css_class = opts[:css_class]
      @attributes = opts[:attributes] || {}
      @width = opts[:width]
      @options = opts
      @display = true
      @index = 0
      @renderer = renderer
    end

    def render_cell(cell_data, row = nil, row_index = 0, col_index = 0)
      @data_type ||= type(cell_data)

      html = []
      html << if @renderer && row
                case @renderer.arity
                when 1 then @renderer.call(cell_data).to_s
                when 2 then @renderer.call(cell_data, row).to_s
                when 3 then @renderer.call(cell_data, row, row_index).to_s
                when 4 then @renderer.call(cell_data, row, row_index, self).to_s
                when 5 then @renderer.call(cell_data, row, row_index, self, col_index).to_s
                end
              else
                cell_data.to_s
              end

      html << '</td>'
      # Doing this here b/c you can't change @css_class if this is done before the renderer is called
      "<td class='#{css_class_names}' #{custom_attributes}>" + html.join
    end

    def render_column_header
      header = ["<th class='#{css_class_names}' #{custom_attributes}"]
      header << "title='#{@help_text}' " if @help_text
      header << "style='width: #{@width}'" if @width
      header << ">#{@description}</th>"
      header.join
    end

    def custom_attributes
      @attributes.map { |k, v| "#{k}='#{v}'" }.join ' '
    end

    def css_class_names
      class_names = []
      class_names << @name.to_s
      class_names << @data_type.to_s
      class_names << @css_class
      class_names.compact.join(' ')
    end

    # Set a CSS class name based on data type
    # For backward compatability, 'string' is renamed to 'text'
    # For convenience, all Numerics (e.g. Integer, BigDecimal, etc.) just return 'numeric'
    def type(data)
      if data.is_a? Numeric
        'numeric'
      elsif data.is_a? String
        'text'
      else
        data.class.to_s.downcase
      end
    end
  end
end
