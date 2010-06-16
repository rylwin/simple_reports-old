require 'test_helper'

class CachedRowTest < ActiveSupport::TestCase

  def setup
    @table_data = [[5, "Vanilla"],
                  [3, "Chocolate"],
                  [7, "Strawberry"]]
    @table = SimpleCachedTable.new(:header => ["Votes", "Flavor"], :row_data => @table_data, :table_key => "simple_table")
    @report = Report::Base.new(:table => @table)    
  end
  
  def teardown
    Report::Table::CachedRow.delete_all
  end

  test "validations" do
    cr1 = Report::Table::CachedRow.new(:table_key => "table1", 
      :row_key => "row1", :data => @table.rows.first.data)
    assert cr1.save
    
    cr2 = Report::Table::CachedRow.new(:table_key => "table1", 
      :row_key => "row1", :data => @table.rows.first.data)
    assert !cr2.save
    
    cr3 = Report::Table::CachedRow.new(:table_key => "table1", 
      :row_key => "row2", :data => @table.rows.first.data)
    assert cr3.save
    
    cr4 = Report::Table::CachedRow.new(:table_key => "table2", 
      :row_key => "row1", :data => @table.rows.first.data)
    assert cr4.save
  end
    
  test "row serialization" do
    @table.cache
    row1 = @table.rows.first
    
    cr1 = Report::Table::CachedRow.find_by_keys("simple_table", "5_Vanilla")
    assert_not_nil cr1
    
    assert_equal row1.data, cr1.data
    
    table = SimpleCachedTable.new(:header => ["Votes", "Flavor"], :table_key => "simple_table")
    # This row exists in the cache
    assert_equal row1.data, table.cached_row("simple_table", "5_Vanilla").data
    
    # This row doesn't exist in the cache
    new_row = table.cached_row("simple_table", "6_Vanilla") {table.new_row([6, "Not Vanilla"])}
    assert_equal [6, "Not Vanilla"], new_row.data
    
    new_row = table.cached_row("simple_table", "6_Vanilla") {[6, "Not Vanilla"]}
    assert_equal [6, "Not Vanilla"], new_row.data
    
  end
  
  test "serialization of all attributes" do
    cr1 = Report::Table::CachedRow.new(:table_key => "table1", 
      :row_key => "row1", :data => @table.rows.first.data, :format => [:text, :text], :row_format => :bold)
    assert cr1.save
    
    cached_cr1 = Report::Table::CachedRow.find_by_keys("table1", "row1")
    assert_equal cr1.format, cached_cr1.format
    assert_equal cr1.row_format, cached_cr1.row_format
  end
  
end
