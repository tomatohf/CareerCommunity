class ViewCounter < ActiveRecord::Base
  
  acts_as_trashable
  
  
  validates_presence_of :counter_key, :view_count
  
  
  
  @@keys = {
    # [cache_key, db_key]
    :talk => ["talk_view_count", 10001],
    :blog => ["blog_view_count", 10002],
    :group_post => ["group_post_view_count", 10003],
    :activity_post => ["activity_post_view_count", 10004],
    :goal_post => ["goal_post_view_count", 10005],
    :company_post => ["company_post_view_count", 10006],
    :exp => ["exp_view_count", 10007],
    :customer_post => ["customer_post_view_count", 10008]
  }
  
  
  def self.keys
    @@keys
  end
  
  
  
  def self.get_count(kind, id)
    count = Cache.get(self.get_cache_key(kind, id))
    
    unless count
      counter = self.get_counter_by_key(kind, id)
      count = (counter && counter.view_count) || 0
      
      self.set_cache_count(kind, id, count)
    end
    count
  end
  
  def self.set_db_count(kind, id)
    cache_count = Cache.get(self.get_cache_key(kind, id))
    
    if cache_count
      counter = self.get_counter_by_key(kind, id)
      if counter && cache_count > counter.view_count
        counter.view_count = cache_count
        counter.save
      end
    end
  end
  
  def self.set_cache_count(kind, id, count)
    Cache.set(self.get_cache_key(kind, id), count, Cache_TTL)
  end
  
  def self.increase_count(kind, id, step = 1)
    count = self.get_count(kind, id)
    count = count + step
    self.set_cache_count(kind, id, count)
    
    add_expired_view_counter(kind, id)
    
    count
  end
  
  def self.get_cache_key(kind, id)
    "#{self.keys[kind][0]}_#{id}".to_sym
  end
  
  def self.get_db_key(kind, id)
    "#{self.keys[kind][1]}#{id}".to_i
  end
  
  
  
  def self.get_counter_by_key(kind, id)
    counter = self.find(
      :first,
      :conditions => ["counter_key = ?", self.get_db_key(kind, id)]
    )
    
    unless counter
      counter = self.new(
        :counter_key => self.get_db_key(kind, id),
        :view_count => 0
      )
      
      counter.save
    end
    
    counter
  end
  
  
  
  # store what have changed and need to update
  CKP_expired_view_counters = :expired_view_counters
  
  def self.get_expired_view_counters
    Cache.get(CKP_expired_view_counters) || {}
  end
  
  def self.add_expired_view_counter(kind, id)
    id = id.to_i
    
    expired_view_counters = self.get_expired_view_counters
    
    ids = expired_view_counters[kind] || []
    ids << id unless ids.include?(id)
    
    expired_view_counters[kind] = ids
    
    Cache.set(CKP_expired_view_counters, expired_view_counters, Cache_TTL)
  end
  
  def self.clear_expired_view_counters_cache
    Cache.delete(CKP_expired_view_counters)
  end
  
  
end


