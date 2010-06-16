module ReportsTextHelper
  
  def text_report(report)
    out = "Report: #{report.title.upcase}\n"
        
    report.tables.each do |table|
      format_table(table)
      # the table_data hash caches information useful in building the table
      @table_data = {}
      out << text_table(table)
    end
    
    out
  end
  
  def text_table(table)
    @table_data = {} unless @table_data
    
    out = table.title ? "\n#{table.title}\n" : ""

    table_width = table_width(table)

    # Output header
    out << text_table_hr(table) 
    out << text_row_data(table, table.header)
    out << text_table_hr(table) 
    
    # Output rows
    table.rows.each do |row|
      out << text_table_hr(table) if row.row_format == :bold and row != table.rows.first
      out << text_row_data(table, row.data)
    end
    out << text_table_hr(table) 

    out
  end
    
  def text_row_data(table, data)
    original_data = data
    # now we have to pad all data with spaces
    
    original_data.each_with_index do |d, i|
      spaces = column_width(table, i) - d.to_s.length
      spaces = spaces > 0 ? spaces : 0
      data[i] = " "*spaces + d.to_s
    end
    
    "| " + data.join(" | ") + " |\n"
  end

  def text_table_hr(table)
    size = (table_width(table) + table.header.size*3 - 1)
    # If size were ever negative (no header, no data), then we would get 
    # a negative argument error that is hard to track down, so just don't let it happen
    size = 0 if size < 0
    
    "+" + "-"*size + "+\n"        
  end
  
  def column_width(table, column_index)
    return @table_data[column_index] if @table_data[column_index]
    
    max_width = table.header[column_index].to_s.length
    
    table.rows.each do |row|
      width = row.data[column_index].to_s.length
      max_width = width if width > max_width
    end
    
    return @table_data[column_index] = max_width
  end
    
  def table_width(table)
    return @table_data[:width] if @table_data[:width]
    
    width = 0
    table.header.each_with_index do |head, i|
      width += column_width(table, i)
    end
    
    @table_data[:width] = width
  end
  
  def row_width(data)
    width = 0
    data.each {|d| width += d.to_s.length}
    width
  end
  
end