module Report

  # Report::Base should be subclassed by all reports. The only method that needs to be implemented
  # is tables, and only if the tables are not passed as an option during initialization.
  class Base
  
    attr_accessor :title, :page_layout
  
    # The following options can be passed when creating a new report:
    # :+title+:: the title for the report. If none is passed, a default title is set.
    # :+page_layout+:: the report page layout, either :portrait or :landscape (default)
    # :+table+:: a single table that comprises the report. This option will have no effect if :tables is also used.
    # :+tables+:: an array of tables that comprise the report. If none are passed, the tables method should be implemented
    def initialize(options={})
      @title = options[:title]||"#{self.class.to_s.demodulize} Report"
      @tables = options[:tables]
      @tables = [options[:table]] if @tables.nil? and !options[:table].nil?
      @page_layout = options[:page_layout]||:landscape
      @options = options
    end
    
    # This method returns the array of tables that comprise this report. If tables were passed as an option to on initialization,
    # then those tables are returned. Otherwise, the create_tables method is called to generate the tables and the results are
    # cached.
    def tables
      @tables||@tables=create_tables
    end
  
    # This method should be overriden to return an array of the table classes that are used in the report. This allows for
    # reflecting on what the report will generate before any tables are actually instantiated.
    def self.table_classes
      "Raise self.table_classes not implemented."
    end
  
    def load_data
      tables.each {|t| t.rows }
    end
  
    def to_xlsx
      ApplicationController.helpers.xlsx_report(self)
    end
  
    def to_text
      ApplicationController.helpers.text_report(self)
    end
  
    def to_file(file_name)
      file = File.new(file_name, 'w')
      file.write(to_text)
      file.close
    end
  
    def table_width
      50
    end
  
    protected

    # Should return the report as a table, which has the form of an array of arrays. A single array contains the whole table, and
    # within that array, each row is represented by an array that contains the data for that row.  
    # Deprecated: from now on, tables method should be overridden.
    def create_tables
      raise "Need to implement abstract method."    
    end
  
  end
end