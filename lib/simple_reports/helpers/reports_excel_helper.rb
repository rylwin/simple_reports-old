# TODO: find out where we got this from and assign credit
module ReportsExcelHelper
    # Class designed to create a multiple-sheet workbook in Excel from ActiveRecord model objects
    # Modified version of http://svn.napcsweb.com/public/excel/lib/excel.rb
	class Workbook
	  
	    def initialize 
	      @worksheets = Array.new
	    end
	    
	    # Add a sheet to the colleection of worksheets.
	    # * sheetname (string) is the name of the worksheet tab
	    # * objectType (string) is the type of object you're sending in.
	    #
	    # * objects is your collection of ActiveRecord objects.
	    #
	    # Here's an example
	    #    
	    #     @book = Book.find(:all)
	    #     @authors = Authors.find(:all)
	    #     addWorksheetFromActiveRecord "Books", "book", @book
	    #     addWorksheetFromActiveRecord "Authors", "author", @authors
	    def addWorksheetFromActiveRecord(sheetname, objectType, objects)
	      
	      objects = [objects] unless objects.class == Array
	    
	      item = [sheetname.to_s, objectType.to_s, objects]
	      @worksheets += [item]
	    end
	    
	    def addWorksheetFromTable(sheetname, table)
	      item = [sheetname.to_s, 'table', table]
	      @worksheets += [item]
      end
	
	    # Returns the Excel workbook in XML format.
	    # In the controller, set the content type appropriately to send this back.
	    #
	    # Example: 
	    #     headers['Content-Type'] = "application/vnd.ms-excel" 
	    #     render_text(e.build)
	    def build
	    	buffer = ""
		    xml = Builder::XmlMarkup.new(buffer)
		    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
		    xml.Workbook({
		      'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
		      'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
		      'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
		      'xmlns:html' => "http://www.w3.org/TR/REC-html40",
		      'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
		      }) do
	    
			      xml.Styles do
			       xml.Style 'ss:ID' => 'Default', 'ss:Name' => 'Normal' do
			         xml.Alignment 'ss:Vertical' => 'Bottom'
			         xml.Borders
			         xml.Font 'ss:FontName' => 'Arial'
			         xml.Interior
			         xml.NumberFormat
			         xml.Protection
			       end
			       
			       xml.Style 'ss:ID' => 'DefaultBold' do
			         xml.Font 'ss:Bold' => '1'
		         end
			       
			       xml.Style 'ss:ID' => 'Date' do
			         xml.NumberFormat 'ss:Format' => 'mm/dd/yy'
			       end

			       xml.Style 'ss:ID' => 'DateBold' do
			         xml.NumberFormat 'ss:Format' => 'mm/dd/yy'
			         xml.Font 'ss:Bold' => '1'
			       end
			       
			       xml.Style 'ss:ID' => 'Currency' do
			         xml.NumberFormat 'ss:Format' => '"$"#,##0.00'
			       end			         

			       xml.Style 'ss:ID' => 'CurrencyBold' do
			         xml.NumberFormat 'ss:Format' => '"$"#,##0.00'
			         xml.Font 'ss:Bold' => '1'
			       end			         
			      end
			      
			      for object in @worksheets
		      		# use the << operator to prevent the < > and & characters from being converted.
		      		# this will concat them together.
		      		if object[1] =='array'
		      		  xml << worksheetFromArray(object[0], object[2])
	            elsif object[1]=='table'
	              xml << worksheetFromTable(object[0], object[2])
	            else
	              xml << worksheet(object[0], object[1], object[2])
	            end
			      end # for records
			    end
			    
	    return xml.target! 
	  end
	
	
	  
	  private
	  
	  # renders an Excel worksheet.
	  # Paramters:
	  #
	  # * sheetname is the name for the worksheet
	  # * objectType is a string for the model type that you're exporting.  For example: if you have a collection of Author objects, "author" would be your type.
	  # * objects is a collection of ActiveRecord objects
	  def worksheet (sheetname, objectType,objects)
	
	      buffer =""
	      xm = Builder::XmlMarkup.new(buffer) # stream to the text buffer
	      type = ActiveRecord::Base.const_get(objectType.classify)
	    
	            xm.Worksheet 'ss:Name' => sheetname do
    	            xm.Table do
    	        
    	              # Header
    	              xm.Row do
    	                for column in type.columns do
    	                  xm.Cell do
    	                    xm.Data column.human_name, 'ss:Type' => 'String'
    	                  end
    	                end
    	              end
    	        
    	              # Rows
    	              for record in objects
    	                xm.Row do
    	                  for column in type.columns do
    	                    xm.Cell do
    	                     xm.Data record.send(column.name), 'ss:Type' => 'String'
    	                    end
    	                  end
    	                end
    	              end # for
    	        
    	            end # table
	          end #worksheet
	       
	      return xm.target!  # retrieves the buffer
	
	  end
	 
	 
	 def worksheetFromArray(sheetname, array)
	   	  buffer =""
	      xm = Builder::XmlMarkup.new(buffer) # stream to the text buffer
	      xm.Worksheet 'ss:Name' => sheetname do
	       xm.Table do
	         #header
	         xm.Row do 
	          
               for key in array[0].keys
                xm.Cell do
                  xm.Data key, 'ss:Type' => 'String'
                end
               end #for
	         end #row
	         
	         #data
	         for item in array
	          
	           xm.Row do 
    	           for value in item.values
    	             xm.Cell do
    	               xm.Data value, 'ss:Type' => 'String'
    	             end
    	           end
	           end
	         end
	         
	         
	       end #table
	      end #worksheet
	      return xm.target!  # retrieves the buffer
	 end  

	  def worksheetFromTable(sheetname, table)
 	   	  buffer =""
 	      xm = Builder::XmlMarkup.new(buffer) # stream to the text buffer
 	      xm.Worksheet 'ss:Name' => sheetname do
 	       xm.Table do
 	         #header
 	         xm.Row do 
                for column in table.header
                   xm.Cell do
                     xm.Data column, 'ss:Type' => 'String'
                   end
                end #for
 	         end #row

 	         #data
 	         for row in table.rows
 	           xm.Row do 
 	               row.data.each_with_index do |value, i|
     	             xm.Cell 'ss:StyleID' => format_to_style(row.format[i], row.has_row_format?(:bold)) do
     	               format, value = xls_format_and_value(i, row, value)
     	               xm.Data value, 'ss:Type' => format
     	             end
     	           end
 	           end
 	         end

 	       end #table
 	      end #worksheet
 	      return xm.target!  # retrieves the buffer
 	 end
 	 
 	 def format_to_style(format, bold=false)
 	   style = 'Default'
 	   case format
     when :date
       style = 'Date'
     when :currency
       style = 'Currency'
     end
     
     style += 'Bold' if bold
          
     style
   end
 	 
 	 def xls_format_and_value(i, row, value)
     format = 'String'

     # If the value is nill, tell excel the format is String; otherwise, it will freak out if trying to format an empty cell
     return format, value if value.blank?

     case row.format[i]
     when :date
       format = 'DateTime'
       value = value.to_time.to_s(:xls) unless value.blank?
     when :number, :number_no_format, :currency
       # From observations, seems like number can't be longer than 30 chars. 
       # Just to be extremely safe, using default number_with_precision, which defaults to 3 digits after the decimal
       value = ActionView::Helpers::NumberHelper.number_with_precision(value)
       format = 'Number'
     end
     
     return format, value
   end
 	 
 end
 
end

