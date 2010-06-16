module ReportsLatexHelper
  
  NEW_ROW = "\\\\\\\\"
  
  # Commands that should be included in the rtex layout file. 
  def simple_reports_latex_commands
    "\\newcommand{\\dollar}{\\$}"
  end
  
  def latex_report(report=@report)
    body = "\\section*{#{l report.title}}\n"
    
    report.tables.each do |table|
      body += "\\subsection*{#{l table.title}}\n" unless table.title.blank?
      body += latex_table(table)
    end
    
    body
  end
  
  def latex_table(table)    
    format_table(table, :latex => true)
    columns = Array.new(table.header.size, "r")
    table.align.each_pair {|index, align| columns[index] = align.to_s.mb_chars.first.to_s}
    columns = columns.join(" ")
    
    "\\begin{table}\n" + 
    "\\begin{longtable}\[l\]{#{columns}}\n" + 
      latex_header_row(table) + 
      latex_rows(table) +
      "\\bottomrule\n" + 
    "\\end{longtable}\n" + 
    "\\end{table}"
  end
  
  def latex_header_row(table)
    row = []
    table.header.each {|h| row << l(h)}
    "\\toprule \n" + row.join(" & ") + "#{NEW_ROW} \\midrule \n"
  end
  
  def latex_rows(table)
    rows = ""
    table.rows.each do |row|
      latex_row = []
      row.data.each {|column| latex_row << l(column)}
      rows << " \\midrule \n" if row.has_row_format?(:bold)
      rows << latex_row.join(" & ") + " #{NEW_ROW}\n"
    end
    rows
  end
end