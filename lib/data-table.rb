# frozen_string_literal: true
require 'data-table/version'
require 'data-table/table'
require 'data-table/column'
require 'data-table/enum'

module DataTable
  def self.render(collection, &_blk)
    # make a new table
    t = DataTable::Table.new(collection)

    # yield it to the block for configuration
    yield t

    # modify the data structure if necessary and do calculations
    t.prepare_data

    # render the table
    t.render
  end

  def self.default_css_styles
    <<-CSS_STYLE
      .data_table {width: 100%; empty-cells: show}
      .data_table td, .data_table th {padding: 3px}

      .data_table caption {font-size: 2em; font-weight: bold}

      .data_table thead th {background-color: #ddd; border-bottom: 1px solid #bbb;}

      .data_table tbody tr.alt {background-color: #eee;}

      .data_table .group_header th {text-align: left;}

      .data_table .subtotal:last-child td,
      .data_table .parent_subtotal:last-child td
      {
        border-top: 1px solid #000;
      }

      .data_table tfoot .total.index_0 td
      {
        border-top: 1px solid #000;
      }

      .empty_data_table {text-align: center; background-color: #ffc;}

      /* Data Types */
      .data_table .number, .data_table .money {text-align: right}
      .data_table .text {text-align: left}

      .level_1,
      .level_2 {
        text-align: left
      }

      .level_2 th {
        padding-left: 35px;
      }
    CSS_STYLE
  end
end
