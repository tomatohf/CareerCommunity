class JobPosition < ActiveRecord::Base
  
  define_index do
    # fields
    indexes :name, :desc

    # attributes
    has :created_at, :updated_at, :account_id
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  
  
  validates_presence_of :name, :message => "请输入 名称"
  
  validates_length_of :name, :maximum => 256, :message => "名称 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "英文名或其他常用名 超过长度限制", :allow_nil => true
  
  
  
  CKP_account_positions = :account_positions
  CKP_position = :position
  
  after_save { |position|
    self.clear_account_positions_cache(position.account_id) if position.account_id && position.account_id > 0
    self.set_position_cache(position)
  }
  
  after_destroy { |position|
    self.clear_account_positions_cache(position.account_id) if position.account_id && position.account_id > 0
    self.clear_position_cache(position.id)
  }
  
  
  
  
  def self.get_account_positions(account_id)
    a_p = Cache.get("#{CKP_account_positions}_#{account_id}".to_sym)
    
    unless a_p
      a_p = self.find(:all, :conditions => ["account_id = ?", account_id], :order => "created_at DESC")
      
      # set individual position cache
      a_p.each { |p| self.set_position_cache(p) }
      
      Cache.set("#{CKP_account_positions}_#{account_id}".to_sym, a_p, Cache_TTL)
    end
    a_p
  end
  
  def self.clear_account_positions_cache(account_id)
    Cache.delete("#{CKP_account_positions}_#{account_id}".to_sym)
  end
  
  
  require_dependency "job_target"
  require_dependency "job_step"
  require_dependency "company"
  def self.get_position(position_id)
    p = Cache.get("#{CKP_position}_#{position_id}".to_sym)
    
    unless p
      p = self.find(position_id)
      
      self.set_position_cache(p)
    end
    p
  end
  
  def self.set_position_cache(position)
    Cache.set("#{CKP_position}_#{position.id}".to_sym, position, Cache_TTL)
  end
  
  def self.clear_position_cache(position_id)
    Cache.delete("#{CKP_position}_#{position_id}".to_sym)
  end
  
  
end


