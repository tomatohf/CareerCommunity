class VoteCategory < ActiveRecord::Base
  
  acts_as_trashable
  
  
  has_many :vote_topics, :class_name => "VoteTopic", :foreign_key => "vote_topic_id", :dependent => :nullify

  # ---

  validates_presence_of :name
  
  CKP_all_categories = :vote_all_categories
  CKP_category = :vote_category
  
  after_destroy { |vote_category|
    self.clear_all_categories_cache
    
    self.clear_category_cache(vote_category.id)
  }
  
  after_save { |vote_category|
    self.clear_all_categories_cache
    
    self.update_category_cache(vote_category.id, vote_category.name)
  }
  
  
  
  def self.get_all_categories
    ac = Cache.get(CKP_all_categories)
    unless ac
      ac = VoteCategory.find(:all, :order => "id DESC").collect { |vc|
        # update single category cache
        update_category_cache(vc.id, vc.name)
        
        [vc.id, vc.name]
      }
      
      Cache.set(CKP_all_categories, ac, Cache_TTL)
    end
    ac
  end
  
  def self.clear_all_categories_cache
    Cache.delete(CKP_all_categories)
  end
  
  def self.get_category(category_id)
    c = Cache.get("#{CKP_category}_#{category_id}".to_sym)
    unless c
    
      c = VoteCategory.find(category_id).name
      
      Cache.set("#{CKP_category}_#{category_id}".to_sym, c)
    end
    c
  end
  
  def self.update_category_cache(category_id, category_name)
    Cache.set("#{CKP_category}_#{category_id}".to_sym, category_name)
  end
  
  def self.clear_category_cache(category_id)
    Cache.delete("#{CKP_category}_#{category_id}".to_sym)
  end
  
  
end

