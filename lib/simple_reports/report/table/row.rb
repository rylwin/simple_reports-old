module Report
  module Table
    class Row
      include Enumerable
  
      # Creates a new row for a Report::Table. The data is an array of the row data. There are also options:
      # +row_format+:: is a format option to be applied to the whole row
      # +format+:: if an array of format options that overrides the Report's default column formatting options
      def initialize(table, data, options={})
        @table = table
        @data = data
        
        # This sets the data array length to the same length as the header; this keeps prawn happy
        @data[table.size-1] = @data[table.size-1] unless table.size == @data.size
    
        @row_format = options[:row_format]
        @cell_format = options[:cell_format]||{}
        @format = options[:format]||table.format
        
        # Currently, has no direct usage, but can be helpful when generating row keys
        @object = options[:object]
        
        @row_key = options[:row_key]
        cache_row if options[:cache_row]
      end
  
      attr_accessor :row_format, :cell_format, :format, :data, :row_key, :object
      attr_writer :row_format, :cell_format, :format
  
      def each(&block)
        @data.each(&block)
      end
  
      def set(heading, value)
        data[@table.index(heading)] = value
      end
  
      def value_at(heading)
        data[@table.index(heading)]
      end
      alias_method :at, :value_at
  
      def has_row_format?(format)
        @row_format.is_a?(Array) ? @row_format.include?(format) : @row_format == format
      end  
      
      def row_key
        @row_key||@table.row_key(self)
      end
      
      def cache
        raise "Cannot cache row because table does not have a table_key." unless @table.table_key
        # TODO: decide what to do with conflicts
        Report::Table::CachedRow.create(:table_key => @table.table_key, :row_key => row_key, 
          :data => @data, :row_format => row_format, :format => format)
      end
    end
  end
end
