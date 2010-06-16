module Report
  module Table
    class Base

      ROW_CLASS = Report::Table::Row
    
      NUMBER_FORMATS = [:number, :number_no_format, :currency, :percent, :float]
      DATE_FORMATS = [:date]
      FONT_SIZES = [:tiny, :small, :normal, :large]
    
      # Create a new table object.
      #
      # Can take several options:
      # +header+:: => Array of header strings
      # +format+:: => Array of formatting options, where each slot in the array is a formatting option (see reports_helper#apply_format) or an array of formatting options for each value in the corresponding data column
      # +title+:: => A title for this table
      # +row_colors+:: => Will cycle through these row colors, including the header row
      # +row_data+:: => Creates rows for the table from the data provided. +row_data+ must be an array of arrays, where each array 
      #                 contains the data for an entire row. If +row_data+ is passed, a +header+ should be 
      #                 provided. Also, passing a +format+ is necessary if the table is to be outputted using one of the formatters.
      #                 Be aware that if +row_data+ is passed, the create_table method will never be called.
      def initialize(options={})
        options ||= {} # make sure options can't be nil
        @rows = []
        self.title = options[:title]
        @row_colors = options[:row_colors]
        self.format = options[:format]||[]
        self.header = options[:header]||[]
        self.font_size = options[:font_size]||:normal
        self.size = header.size
        @table_key = options[:table_key]
        @sortable = options[:sortable].nil? ? true : options[:sortable]
        @sort_by = options[:sort_by]||header.first
    
        @sort_order = options[:sort_order].blank? ? "asc" : options[:sort_order].downcase
        @sort_order = @sort_order == "desc" ? false : true

        import_row_data(options[:row_data]) if options[:row_data]
      end
  
      attr_accessor :title, :row_colors, :header, :format, :size, :sortable, :sort_by, :sort_order, :font_size
  
      def font_size=(size)
        raise "Not a valid size" unless FONT_SIZES.include?(size)
        @font_size = size
      end
  
      # Returns the name of the table. If the full class is Report::Table::SomeTable, then some_table is returned.
      def self.name
        self.to_s.underscore.split("/").last
      end
      
      def name
        self.class.name
      end
  
      # Returns the header array of the table
      def self.header
        raise "self.header not implemented"
      end
  
      def header
        @header.empty? ? self.class.header : @header
      end
  
      # Should return an array with the corresponding format of each column. If format returns an empty array, no formatting is applied.
      # It is also permitted to leave some columns with a 'nil' format, so that it will not be formated. Some possible format options:
      # +currency+:: formats as currency
      # +long_date+:: long date
      # +short_date+:: short date
      # +percent+:: percentage
      #
      # These formats are applied by ReportsHelper#format_data
      def format
        @format
      end
  
      # This method is called when outputting the table to decide how each column should be aligned. Numbers, currencies, percents, and
      # floats are all right-aligned. Everything else is left-aligned by default. If different alignment preferecens are required,
      # this method can be overridden.
      def align
        align = {}
        format.each_with_index do |format, index|
          align[index] = (NUMBER_FORMATS.include?(format) ? :right : :left)
        end
        align
      end
    
      # Can be overwritten to define column widths in the form of a hash: {column_number => PDF points}
      def column_widths
        {}
      end

      # This method calls create_table to generate the table data. It caches the results so that the table is not re-generated when
      # rows is called again. In order to re-generate the whole table, reset should be called first, which clears out the data.
      def rows
        if @rows.empty?
          start_time = Time.now.to_f
          if should_cache? and cached?
            load_table_from_cache
          else
            create_table 
            cache if should_cache?
          end
          end_time = Time.now.to_f
          @table_time = end_time - start_time          
        end
    
        @rows
      end  
  
      # Finds the first row to match the value in the provided column. If a column isn't provided, then the first
      # column is used by default. Returns nil if no rows match
      def find(value, column=nil)
        column = header.first unless column
    
        rows.each do |row|
          return row if row.value_at(column) == value
        end
    
        return nil
      end
  
      # Clears out any loaded table data. Should be called in order to allow regenerating table.
      def reset
        @rows = nil
      end
  
      # The time it took to generate the table in milliseconds.
      def table_time
        @table_time * 1000
      end
  
      # The column index of a given heading.
      def index(heading)
        col = header.index(heading)
        raise "Heading '#{heading}' not in table." if col.nil?
        col
      end
  
      # Deprecated: should use Report::Table::Row.set instead
      def set(row, heading, value)
        row[index(heading)] = value
      end
  
      # Sums up the values in a column, as denoted by the column heading.
      def sum(heading)
        sum = 0
        @rows.each {|row| sum += (row.data[index(heading)].blank? ? 0.0 : row.data[index(heading)])}
        sum
      end
      
      # Averages the values in a column. This method uses the #sum and divides by the number of rows in the table.
      def avg(heading)
        sum(heading)/rows.size.to_f
      end
    
      # Creates a new row in the table.
      def new_row(data=[], options ={})
        @rows << self.class::ROW_CLASS.new(self, data, options)
        @rows.last
      end
      
      # Loads a cached row into the table. If none is found, the passed block is executed to create the new row. This block
      # can be used to call new_row to add the row or, if the result of the block is not a Report::Table::Row, this method
      # will create a new row using the block result.
      def cached_row(table_key, row_key, &new_row_code)
        if cached_row = Report::Table::CachedRow.find_by_keys(table_key, row_key)
          new_row cached_row.data
        else
          result = new_row_code.call
          if result.class == ROW_CLASS
            return result
          else
            new_row(result)
          end
        end
      end
    
      # Caches the table by calling cache on each row.
      def cache
        rows.each(&:cache)
      end      
      
      # Loads the table by fetching all CachedRows that match the table's key.
      def load_table_from_cache
        Report::Table::CachedRow.find_each(:conditions => {:table_key => table_key}) { |cr| @rows << cr.to_row(self) }
      end
      
      # Returns true if a cached row exists for this table.
      # This method may need to be overriden for more complex behavior.
      def cached?
        Report::Table::CachedRow.exists_for_table?(table_key)
      end
      
      # By default, false. However, this can be overridden to turn caching on.
      def should_cache?
        false
      end
  
      # Sorts all rows currently in the table.
      # * column (String): The string must match an existing header string
      # * asc (Bool): If true, then the sort is in ascending order. Otherwise, descending. True by default
      # --
      # TODO: get sort by multiple columns to work
      def sort(column=@sort_by, asc = @sort_order)
        column_format = format[index(column)]
        x_sort_string =  "x.data[index('#{column}')]"
        y_sort_string = "y.data[index('#{column}')]"
    
        if !(NUMBER_FORMATS + DATE_FORMATS).include? format[index(column)]
          x_sort_string = x_sort_string + ".to_s"
          y_sort_string = y_sort_string + ".to_s"
        end
        
        if NUMBER_FORMATS.include? format[index(column)]
          x_sort_string = x_sort_string + ".to_f"
          y_sort_string = y_sort_string + ".to_f"          
        end

        # Sort the rows:
        # By returning -1 in case the comparison fails, we ensure that the sort never raises an error; however,
        # we may not get a proper sort, but it's better to have the app not fail
        @rows.sort! {|x, y| (instance_eval(x_sort_string) <=> instance_eval(y_sort_string)) || -1}
    
        @rows.reverse! unless asc
      end
    
      def to_csv
        csv=""
        csv << header.collect{|d| "\"#{d}\""}.join(",") + "\n"
        rows.each do |row|
          # sanitize the data by surrounding in quotes
          data = row.data.collect {|d| "\"#{d}\""}
          # insert commas between each column of data, stick on a newline char, and place the row in or csv output
          csv << data.join(",") + "\n"
        end
        csv
      end
      
      def to_text
        ApplicationController.helpers.text_table(self)
      end
      
      def to_latex
        ApplicationController.helpers.latex_table(self)
      end
      
      def to_html
        ApplicationController.helpers.html_table(self)
      end
      
      def to_chart_url(type=:line)
        ApplicationController.helpers.table_chart_url(type, self)
      end
      
      def to_s(format=:text)
        send("to_#{format}")
        # to_text
      end
  
      def table_key
        @table_key || nil #raise("No table_key defined. Either pass a table_key to the table as an option or override table_key method.")
      end
      
      def row_key(row)
        raise "No row_key defined. Either pass a table_key to the table as an option or override row_key method."
      end
  
      protected

      # Should return the report as a table, which has the form of an array of Report::Table::Rows.   
      def create_table
        raise "Need to implement abstract method."    
      end
      
      def import_row_data(data_arrays)
        data_arrays.each do |data|
          new_row data
        end
      end
  
    end
  end
end
