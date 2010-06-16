module SimpleReportsHelper
  include ReportsTextHelper
  include ReportsExcelHelper
  # Don't really need this includes, but it makes it obvious where the other methods are coming from
  include ReportsPrawnHelper
  include ReportsHtmlHelper
  include ReportsLatexHelper
  include ReportsChartHelper
  
  def xlsx_report(report=@report)
    e = ReportsExcelHelper::Workbook.new
    report.tables.each_with_index do |table, i|
      title = table.title.blank? ? "Sheet #{i+1}" : table.title
      e.addWorksheetFromTable title, table
    end
    e.build
  end
    
  # This method formats a table.
  def format_table(table=@table, options={})
    table.rows.each do |row|
      row.each_with_index do |data, i|
        next unless table.format[i]
        # apply column formats
        row.data[i] = apply_format(row.format[i], row.data[i], options)
        # apply special all row format
        row.data[i] = apply_format(row.row_format, row.data[i], options)
      end
    end
    table
  end
  
  # Applies formatting to data. Format can be a single format symbol (see format_data for list of symbols), 
  # or an array of format symbols.
  def apply_format(format, data, options={})
    return data if data.nil? or format.nil?
        
    if format.is_a? Array
      format.each {|format| data = format_data(format, data, options)}
      data
    else
      format_data(format, data, options)
    end
    
  end
  
  #TODO: cnu percent and currency all rely on helpers from main project!!! We definitely don't want this!
  
  # TODO: make sure all formats in this list are better documented and all handeled by excel
  
  # This method is a helper for apply_format, and should not be called directly by other methods. It formats data, where format can be:
  # :text, :number, :float, :percent, :currency, :long_date, :short_date, :date (alias for short_date), :time, :bold.
  #
  # If a format is passed that is not in the list, then an exception is raised, stating that the format does not exist.
  def format_data(format, data, options)
    return "" if data.blank?
    
    case format
    when :text
      return data
    when :number
      return cnu(data, 0)
    when :number_no_format
      return data
    when :one_decimal
      return cnu(data, 1)
    when :float
      return cnu(data, 2)
    when :long_float
      return cnu(data, 4)
    when :percent
      return percent(data)
    when :currency
      ret = currency(data)
      ret.gsub!("\$", "\\dollar ") if options[:latex]
      return ret
    when :long_date
      # we convert the data to_time because the formatting will not be applied if it is a Date object
      return data.to_time.to_s(:long_date)
    when :short_date, :date
      return data.to_time.to_s(:mdy) 
    when :time
      return data.to_s(:time)
    when :bold
      return content_tag(:b, data)
    end
    
    raise "Format #{format} does not exist."
  end
      
end
