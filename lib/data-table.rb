require "data-table/version"
require "data-table/table"
require "data-table/column"

module DataTable
  def self.render(collection, &blk)
      # make a new table
      t = DataTable::Table.new(collection)

      # yield it to the block for configuration
      yield t

      # modify the data structure if necessary and do calculations
      t.prepare_data

      # render the table
      t.render.html_safe
    end
end
