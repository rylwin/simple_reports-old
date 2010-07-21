module ReportsHtmlHelper
  # Write a report in HTML format. Writes a header, then each table in the report, including each table's title if it has one.
  def html_report(report=@report)
    header = content_tag(:h2, report.title)
    
    body = ""
    
    report.tables.each do |table|
      body += html_table(table)
    end
    
    (header + body.html_safe)
  end
  
  def html_table(table)
    format_table(table)
    html_class = "report #{table.name}"
    html_class += " sortable" if table.sortable
    html_class += " #{table.font_size}"
    if table.is_a?(Report::Table::Map)
      table_output = html_map(table)
    else
      table_output = content_tag(:table, html_inner_table(table), :class => html_class, :table_name => table.name)
    end
    (table_title(table) + table_output)
  end
  
  def html_map(table)
    @html_map_div_count ||= 1
    map = Mapstraction.new("map_div_#{@html_map_div_count}", SimpleReports::MAP[:service])
    @html_map_div_count += 1
    
    map.control_init(:small => true)
    map.center_zoom_init(table.center, table.zoom)
    
    marker_array = []
    table.rows.each do |row|
      marker_array << Marker.new([row.at("LAT"),row.at("LNG")], :label => row.at("LABEL"), :info_bubble => row.at("INFO"))
    end

    clusterer = Clusterer.new(marker_array)
    map.clusterer_init(clusterer)    

    content_for(:map_header) do
      # javascript_include_tag('clusterer')
      Mapstraction.header(SimpleReports::MAP[:service]) + map.to_html
    end
    
    map.div(:width => 600, :height => 400).html_safe
  end
    
  def table_title(table)
    return content_tag(:h3, table.title) if table.title
    return "" # return empty string if there is no title
  end
  
  def html_inner_table(table=@table)
    html_header_row(table) + html_data_rows(table)
  end
  
  def html_data_rows(table=@table)
    rows = "<tbody>"  
    tbody_ended = false
    table.rows.each do |row| 
      inner_row_html = ""
      row.data.each_with_index do |column, index|
        html_class = table.align[index].to_s
        inner_row_html << content_tag(:td, column, :class => html_class)
      end
      tbody_end = ''
      # TODO: instead of relying on summary/total rows being bolded, come up with a row divider instead
      if !tbody_ended and row.has_row_format?(:bold)
        tbody_ended = true
        tbody_end = '</tbody><tfoot>'
      end
      rows << tbody_end + content_tag(:tr, inner_row_html)
    end
        
    rows + (tbody_ended ? '</tfoot>' : '</tbody>')
  end
  
  def html_header_row(table=@table)
    start_row = "<thead><tr>" 
    header_cells = ''
    table.header.each do |column|
      header_cells += html_header_cell(column, table)
    end
    end_row = "</tr></thead>"
    
    start_row + header_cells + end_row
  end
    
  def html_header_cell(column, table=@table)
    options = {}
    if table.sortable and column == table.sort_by
      options.merge!(:class => "sort#{table.sort_order ? "asc" : "desc"}")
    end
    
    content_tag(:th, column, options)
  end
  
end