require 'test_helper'

class SimpleReportsTest < ActiveSupport::TestCase

  # Tests an extremely basic table for data entry and pull. The table used here is generated on the fly.
  test "basic table" do
    table_data = [[5, "Vanilla"],
                  [3, "Chocolate"],
                  [7, "Strawberry"]]

    report = Report::Base.new(:table => Report::Table::Base.new(:header => ["Votes", "Flavor"], :row_data => table_data))
    table = report.tables.first


    table_data.each_with_index do |row_data, row_i|
      row_data.each_with_index do |data, column_i|
        assert_equal data, table.rows[row_i].data[column_i]
      end
    end
  end
  
end
