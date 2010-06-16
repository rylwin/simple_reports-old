module Report
  module Table
    class Map < Report::Table::Base
      
      ROW_CLASS = Report::Table::MapRow
      
      def initialize(options={})
        super(options)
        options ||= {} # make sure options can't be nil
        self.center = options[:center]
        self.zoom = options[:zoom]
      end
      
      attr_accessor :center, :zoom
      
      def self.header
        ["LAT", "LNG", "LABEL", "INFO"]
      end
      
      def format
        [:number_no_format, :number_no_format, :text, :text]
      end
      
      # Returns the center of the map. If one is not provided by the 
      # user (e.g. map.center = [12.23, 18.44] or Report::Table::Map.new(:center => [12.23, 18.44])), then
      # a center is automatically calculated using +calculate_center+.
      def center
        @center||calculate_center
      end
      
      def calculate_center
        [avg("LAT"), avg("LNG")]
      end
      
      # Returns the zoom level for the map. If one is not provided by the 
      # user (e.g. map.zoom = 5 or Report::Table::Map.new(:zoom => 5)), then
      # a zoom level is automatically calculated using +calculate_zoom+.
      def zoom
        @zoom||calculate_zoom
      end
      
      # Calculates the maximum distance of any row from the center of the table.
      def max_distance_from_center
        distance = 0
        center = ::Geokit::LatLng.new(calculate_center[0], calculate_center[1])
        
        rows.each do |row|
          row_distance = center.distance_from([row.lat, row.lng]).abs
          distance = row_distance if row_distance > distance
        end
        
        distance
      end
      
      # Calculate the zoom level for this table based on the maximum distance of any row from the center of the map.
      # These zooms levels are intended to correspond to Google Map zoom levels. These zoom levels are really just
      # guesses for now.
      def calculate_zoom
        radius = max_distance_from_center
        if radius < 5
          12
        elsif radius < 10
          11
        elsif radius < 20
          10
        elsif radius < 100
          8
        elsif radius < 200
          7
        elsif radius < 400
          5
        elsif radius < 600
          4
        else 
          3
        end
      end
      
      def create_table
      end
    
    end
  end
end