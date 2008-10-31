class City < ActiveRecord::Base
  
  belongs_to :province, :class_name => "Province", :foreign_key => "province_id"
  
  def self.get_name(city_id, all_provinces_cities_cache = nil)
    return nil unless city_id
    
    all_provinces_cities_cache ||= Province.get_all_provinces_cities
    
    all_provinces_cities_cache.values.each do |cities|
      cities.each do |city|
        return city[1] if city[0].to_s == city_id.to_s
      end
    end
  end
  
end
