module Report
  module Table
    class MapRow < Row
      
      def lat
        at("LAT")
      end
      
      def lng
        at("LNG")
      end
      
      def to_lat_lng
        ::Geokit::LatLng.new(lat, lng)
      end
    end
  end
end
