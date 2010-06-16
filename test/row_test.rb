require 'test_helper'

class CachedRowTest < ActiveSupport::TestCase

  def setup
    @table_data = [[5, "Vanilla"],
                  [3, "Chocolate"],
                  [7, "Strawberry"]]
    @table = SimpleCachedTable.new(:header => ["Votes", "Flavor"], :row_data => @table_data, :table_key => "simple_table")
    @report = Report::Base.new(:table => @table)    
  end
    
  test "row caches" do
    @table.cache
    
    cached_table = Report::Table::Base.new(:header => ["Votes", "Flavor"], :table_key => "simple_table")
    cached_table.load_table_from_cache

    %w(data format row_format).each do |field|
      assert_equal @table.rows.first.send(field), cached_table.rows.first.send(field), "#{field.to_s.titleize} did not match"
    end
  end
    
end
