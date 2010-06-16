module ReportsPrawnHelper
  # Writes a pdf report for a Report. This method writes out a header, then proceeds to print out the table, including the
  # table's title if it has one. If there is no data in the two dimensional array, the method simple prints "Report contains
  # no data" to the PDF.
  def pdf_report(pdf, report)
    pdf_header(pdf, report)
    
    pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 10], :width  => pdf.bounds.width, :height => pdf.bounds.height - 10) do
      report.tables.each do |table|
        if table.is_a?(Report::Table::Map)
          pdf_map(pdf, table)
        else
          pdf_table(pdf, table)
        end
      end
   end
  end
  
  def pdf_table(pdf, table)
    # pdf.table will raise exception if there is no data, so check for this and let the user know there is no data
    if table.rows.empty?
      pdf.text "Report contains no data."
    else
      if table.title
        pdf.font "Times-Roman" do
          pdf.move_down(10)
          pdf.text(table.title, :size => 10) 
        end
      end
      pdf.font "Times-Roman" do
      pdf.table(table_to_array_of_arrays(format_table(table)),
        :position => :left,
      	:headers => table.header.map{|heading| heading.to_s.humanize},
      	:align_headers => :center,
      	:align => table.align,
      	:border_style => :underline_header,
        :row_colors => table.row_colors||:pdf_writer,
      	:column_widths => table.column_widths,
      	:padding => 2,
      	:font_size => table_font_size_in_pts(table))
    	end
    end
  end
  
  def pdf_map(pdf, table)    
    pdf.start_new_page
    size = "540x720" # 7.5in x 10in
    pdf.image open(google_maps_static_uri("#{table.center[0]},#{table.center[1]}", table.zoom, size, table.rows))
  end
  
  def google_maps_static_uri(center, zoom, size, rows)
    base = "http://maps.google.com/maps/api/staticmap?center=#{center}&zoom=#{zoom}&size=#{size}&maptype=roadmap&sensor=false"
    rows.each do |row|
      base += "&markers=#{row.lat},#{row.lng}"
    end
    base
  end
  
  def table_font_size_in_pts(table)
    case table.font_size
    when :large
      return 10
    when :normal
      return 9
    when :small
      return 8
    when :tiny
      return 7
    end
    raise "No font size maps to #{table.font_size}"
  end
  
  # Create a header for PDFs. Used by reports to create report headers.
  def pdf_header(pdf, report)
    # TODO: when we can use prawn >= 0.7.1, use the pdf.page_number method instead of counting ourselves
    @page_count = 0
    pdf.header [pdf.margin_box.left, pdf.margin_box.top + 10] do
      pdf.font "Helvetica" do
        pdf.text report.title, :size => 12, :align => :left
        pdf.move_up(16) # move back up so that the next two lines are more or less even with the title line
        pdf.text Time.now, :size => 8, :align => :right
        pdf.text "Page: #{@page_count = @page_count + 1}", :size => 8, :align => :right
        pdf.stroke_horizontal_rule
      end
    end
  end
  
  def move_down_by_factor(pdf, factor)
    pdf.move_down(pdf.font_size * factor)
  end
  
  # This method converts a Report::Table to a two-dimensional array, which is the format easiest to use in outputting and
  # also expected by the prawn table method.
  def table_to_array_of_arrays(table=@table)
    array = []
    table.rows.each do |row|
      row_array = []
      row.data.each_with_index do |column, index|
        data = {:text => column}
        if row.cell_format.is_a? Hash
          data.reverse_merge! row.cell_format
        elsif row.cell_format.is_a? Array
          data.reverse_merge! row.cell_format[index]
        end
        row_array << Prawn::Table::Cell.new(data)
      end
      array << row_array
    end
    array
  end
end