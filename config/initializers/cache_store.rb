class Cache
  
  def self.get(key)
    Rails.cache.read(key.to_s)
  end
  
  
  def self.set(key, value, ttl = 0)
    Rails.cache.write(key.to_s, value, :expires_in => ttl)
  end
  
  
  def self.delete(key)
    Rails.cache.delete(key.to_s)
  end
  
end
