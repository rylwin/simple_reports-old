require 'test_helper'

class MapTest < ActiveSupport::TestCase

  # Tests an extremely basic table for data entry and pull. The table used here is generated on the fly.
  test "center and zoom" do
    table = Report::Table::Map.new(
      :row_data => [[0,0], [1,1]]
    )
    
    assert_equal Report::Table::MapRow, table.rows.first.class
    
    assert_equal [0.5, 0.5], table.center

    table.center = [2,2]
    assert_equal [2, 2], table.center

    table.center = nil
    assert_equal [0.5, 0.5], table.center
    
    assert table.max_distance_from_center > 0
    
    table.zoom = 1
    assert_equal 1, table.zoom
    table.zoom = nil
    assert_not_equal 1, table.zoom
  end
  
end
