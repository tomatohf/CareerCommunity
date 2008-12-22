class ActivityInterest < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  belongs_to :activity, :class_name => "Activity", :foreign_key => "activity_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :activity_id, :account_id
  
  
  
  FCKP_spaces_show_activity_interest = :fc_spaces_show_activity_interest
  
  CKP_activity_interest = :activity_interest
  
  after_save { |activity_interest|
    self.clear_spaces_show_activity_interest_cache(activity_interest.account_id)
    
    self.set_activity_interest_cache(activity_interest.activity_id, activity_interest.account_id, activity_interest)
  }
  
  after_destroy { |activity_interest|
    self.clear_spaces_show_activity_interest_cache(activity_interest.account_id)
    
    self.clear_activity_interest_cache(activity_interest.activity_id, activity_interest.account_id)
  }
  
  def self.clear_spaces_show_activity_interest_cache(account_id)
    Cache.delete(expand_cache_key("#{FCKP_spaces_show_activity_interest}_#{account_id}"))
  end
  
  
  
  def self.get_activity_interest(activity_id, account_id)
    a_i = Cache.get("#{CKP_activity_interest}_#{activity_id}_#{account_id}".to_sym)
    
    unless a_i
      a_i = self.find(:first, :conditions => ["activity_id = ? and account_id = ?", activity_id, account_id])
      
      self.set_activity_interest_cache(activity_id, account_id, a_i)
    end
    a_i
  end
  
  def self.set_activity_interest_cache(activity_id, account_id, interest)
    Cache.set("#{CKP_activity_interest}_#{activity_id}_#{account_id}".to_sym, interest && interest.clear_association, Cache_TTL)
  end
  
  def self.clear_activity_interest_cache(activity_id, account_id)
    Cache.delete("#{CKP_activity_interest}_#{activity_id}_#{account_id}".to_sym)
  end
  
  
  
  def self.is_interest_activity(account_id, activity_id)
    self.get_activity_interest(activity_id, account_id)
  end
  
  def self.add_interest_activity(account_id, activity_id)
    activity_interest = ActivityInterest.new(:account_id => account_id, :activity_id => activity_id)
    activity_interest.save
  end
  
  def self.paginate_activity_interest_accounts(activity_id, page, page_size)
    self.paginate(
      :page => page,
      :per_page => page_size,
      :conditions => ["activity_id = ?", activity_id],
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
  end
  
  
  def self.load_activity_with_image(interests)
    preload_associations(interests, [:activity => [:image]])
  end
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end