class Province < ActiveRecord::Base
  
  has_many :cities, :class_name => "City", :foreign_key => "province_id", :dependent => :destroy

  def self.get_all_provinces_cities
    all_provinces_cities = Cache.get(:all_provinces_cities)
    unless all_provinces_cities
      all_provinces_cities = {}
      self.find(:all, :include => :cities).each { |p|
        all_provinces_cities[[p.id, p.name]] = p.cities.collect {|c| [c.id, c.name] }
      }
      # use the default expires time +0+, which means *never expire*
      Cache.set(:all_provinces_cities, all_provinces_cities)
    end
    all_provinces_cities
  end
  
  def self.clear_all_provinces_cities_cache
    Cache.delete(:all_provinces_cities)
  end
  
  def self.get_name(province_id, all_provinces_cities_cache = nil)
    return nil unless province_id
    
    all_provinces_cities_cache = self.get_all_provinces_cities
    
    all_provinces_cities_cache.keys.each do |key|
      return key[1] if key[0].to_s == province_id.to_s
    end
  end
  
end
