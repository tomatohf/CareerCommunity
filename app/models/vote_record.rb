class VoteRecord < ActiveRecord::Base
  
  belongs_to :topic, :class_name => "VoteTopic", :foreign_key => "vote_topic_id"
  belongs_to :option, :class_name => "VoteOption", :foreign_key => "vote_option_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  
  validates_presence_of :account_id, :vote_topic_id, :vote_option_id
  
  
  
  CKP_count_by_option = :vote_record_count_by_option
  CKP_voter_count = :vote_record_voter_count
  CKP_voted_records = :vote_record_account_voted_records
  CKP_voted_records_by_ip = :vote_record_ip_voted_records
  
  after_destroy { |vote_record|
    self.decrease_count_by_option_cache(vote_record.vote_option_id)
    
    self.clear_voter_count_cache(vote_record.vote_topic_id)
    
    if (vote_record.account_id == 0)
      self.clear_voted_records_by_ip_cache(vote_record.vote_topic_id, vote_record.voter_ip)
    else
      self.clear_voted_records_cache(vote_record.vote_topic_id, vote_record.account_id)
    end
  }
  
  after_save { |vote_record|
    self.increase_count_by_option_cache(vote_record.vote_option_id)
    
    self.clear_voter_count_cache(vote_record.vote_topic_id)
    
    if (vote_record.account_id == 0)
      self.clear_voted_records_by_ip_cache(vote_record.vote_topic_id, vote_record.voter_ip)
    else
      self.clear_voted_records_cache(vote_record.vote_topic_id, vote_record.account_id)
    end
  }
  
  
  
  def self.get_voted_records(topic_id, account_id)
    vr = Cache.get("#{CKP_voted_records}_#{topic_id}_#{account_id}".to_sym)
    unless vr
      vr = self.find(:all, :conditions => ["vote_topic_id = ? and account_id = ?", topic_id, account_id]).collect do |record|
        [record.vote_option_id, record.voter_ip]
      end
      
      Cache.set("#{CKP_voted_records}_#{topic_id}_#{account_id}".to_sym, vr, Cache_TTL)
    end
    vr
  end
  
  def self.set_voted_records_cache(topic_id, account_id, records)
    vr = records.collect do |record|
      [record.vote_option_id, record.voter_ip]
    end
    
    Cache.set("#{CKP_voted_records}_#{topic_id}_#{account_id}".to_sym, vr, Cache_TTL)
  end
  
  def self.clear_voted_records_cache(topic_id, account_id)
    Cache.delete("#{CKP_voted_records}_#{topic_id}_#{account_id}".to_sym)
  end
  
  
  def self.get_voted_records_by_ip(topic_id, ip = "")
    ip.strip!
    
    vr = Cache.get("#{CKP_voted_records_by_ip}_#{topic_id}_#{ip}".to_sym)
    unless vr
      vr = self.find(:all, :conditions => ["vote_topic_id = ? and account_id = ? and voter_ip = ?", topic_id, 0, ip]).collect do |record|
        [record.vote_option_id]
      end
      
      Cache.set("#{CKP_voted_records_by_ip}_#{topic_id}_#{ip}".to_sym, vr, Cache_TTL)
    end
    vr
  end
  
  def self.clear_voted_records_by_ip_cache(topic_id, ip = "")
    ip.strip!
    
    Cache.delete("#{CKP_voted_records_by_ip}_#{topic_id}_#{ip}".to_sym)
  end
  
  
  def self.get_voter_count(topic_id)
    c = Cache.get("#{CKP_voter_count}_#{topic_id}".to_sym)
    unless c
      c = self.count(
        :distinct => true,
        :select => "account_id, voter_ip",
        :conditions => ["vote_topic_id = ?", topic_id]
      )
      
      Cache.set("#{CKP_voter_count}_#{topic_id}".to_sym, c, Cache_TTL)
    end
    c
  end
  
  def self.clear_voter_count_cache(topic_id)
    Cache.delete("#{CKP_voter_count}_#{topic_id}".to_sym)
  end
  
  
  def self.get_count_by_option(option_id)
    c = Cache.get("#{CKP_count_by_option}_#{option_id}".to_sym)
    unless c
      c = self.count(:conditions => ["vote_option_id = ?", option_id])
      
      Cache.set("#{CKP_count_by_option}_#{option_id}".to_sym, c, Cache_TTL)
    end
    c
  end
  
  def self.increase_count_by_option_cache(option_id, count = 1)
    c = Cache.get("#{CKP_count_by_option}_#{option_id}".to_sym)
    if c
      updated_c = c.to_i + count
      
      Cache.set("#{CKP_count_by_option}_#{option_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.decrease_count_by_option_cache(option_id, count = 1)
    c = Cache.get("#{CKP_count_by_option}_#{option_id}".to_sym)
    if c
      updated_c = c.to_i - count
      
      Cache.set("#{CKP_count_by_option}_#{option_id}".to_sym, updated_c, Cache_TTL)
    end
  end
  
  def self.clear_count_by_option_cache(option_id)
    Cache.delete("#{CKP_count_by_option}_#{option_id}".to_sym)
  end
  
  
  
  def self.count_by(field, value)
    self.count(:conditions => ["#{field} = ?", value])
  end
  
end


