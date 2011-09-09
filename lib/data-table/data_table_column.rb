class DataTableColumn
 
  attr_reader :name
  attr_accessor :display, :index, :options, :css_class, :attributes
  
  def initialize(name, description="", opts={}, &renderer)
    @name, @description, = name, description
    @data_type = opts[:data_type] || :text
    @help_text = opts[:help_text] || ""
    @css_class = opts[:css_class]
    @attributes = opts[:attributes] || {}
    @width = opts[:width]
    @options = opts
    
    @display = true
    @index = 0
    @renderer = renderer
  end
  
  def render_cell(cell_data, row=nil, row_index=0, col_index=0)
    html = ""
    if @renderer && row
      cell_data = cell_data.to_s
      html << case @renderer.arity
            when 1; @renderer.call(cell_data).to_s
            when 2; @renderer.call(cell_data, row).to_s
            when 3; @renderer.call(cell_data, row, row_index).to_s
            when 4; @renderer.call(cell_data, row, row_index, self).to_s
            when 5; @renderer.call(cell_data, row, row_index, self, col_index).to_s
          end
    else
      html << cell_data.to_s
    end
    
    html << "</td>"
    # Doing this here b/c you can't change @css_class if this is done before the renderer is called
    html = "<td class='#{css_class_names}' #{custom_attributes}>" + html
  end
  
  def render_column_header
    header = "<th class='#{css_class_names}' #{custom_attributes}" 
    header << "title='#{@help_text}' " if @help_text
    header << "style='width: #{@width}'" if @width
    header << ">#{@description}</th>"
    header
  end
  
  def custom_attributes
    @attributes.map{|k, v| "#{k}='#{v}'"}.join ' '
  end
  
  def css_class_names
    class_names = []
    class_names << @name.to_s
    class_names << @data_type.to_s
    class_names << @css_class
    class_names.compact.join(' ')
  end
  
end