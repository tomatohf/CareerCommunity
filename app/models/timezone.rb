class Timezone < ActiveRecord::Base

  def get_rails_time_zone
    TimeZone.create self.name, self.offset
  end
  
  @@all_timezones = nil
  def Timezone.all_timezones
    @@all_timezones = Timezone.find(:all) unless @@all_timezones
    @@all_timezones
  end
  
  def Timezone.clear_cached_all_timezones
    @@all_timezones = nil
  end

end
