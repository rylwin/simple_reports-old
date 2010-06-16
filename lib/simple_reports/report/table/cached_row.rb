module Report
  module Table
    class CachedRow < ActiveRecord::Base
      validates_uniqueness_of :row_key, :scope => :table_key
  
      serialize :data, Array
      serialize :format
      serialize :row_format
      
      def self.find_by_keys(table_key, row_key)
        CachedRow.find_by_table_key_and_row_key(table_key, row_key)
      end
      
      def self.find_all(table_key)
        CachedRow.find_all_by_table_key(table_key)
      end
      
      def self.exists_for_table?(table_key)
        !CachedRow.find_by_table_key(table_key).nil?
      end
      
      def to_row(table)
       table.class::ROW_CLASS.new(table, data, row_options)
      end
      
      def row_options
        {:format => format, :row_format => row_format}
      end
    end
  end
end