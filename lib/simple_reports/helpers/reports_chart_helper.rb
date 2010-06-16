module ReportsChartHelper

  # orange (google standard color), blue-ish
  COLORS = ['ff9900', '0099ff']
  
  def table_chart_url(type, table, options={})
    options.reverse_merge!(:size => '320x200', :title => table.title)
    chart_class = "GoogleChart::#{type.to_s.camelize}Chart".constantize
    url = ''
    chart_class.new(options[:size], options[:title], false) do |chart|
      headers = table.header[1, table.header.length] # don't iterate over first column, this will be axis
      headers.each_with_index do |column, index|
        chart.data column, table.rows.map {|r| r.value_at(column)}, COLORS[index]
      end
      url = chart.to_url
    end
    url
  end
  
end