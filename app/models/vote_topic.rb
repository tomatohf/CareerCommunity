class VoteTopic < ActiveRecord::Base
  
  acts_as_trashable
  
  
  define_index do
    # fields
    indexes :title, :desc
    indexes category.name, :as => :category_name
    indexes account.nick, :as => :account_nick
    indexes options.title, :as => :options_title
    indexes comments.content, :as => :comments_content
    indexes comments.account.nick, :as => :comments_account_nick

    # attributes
    has :created_at, :updated_at, :multiple, :allow_add_option, :allow_clear_record
    
    set_property :delta => true
    
    # set_property :field_weights => {:field => number}
  end
  
  include CareerCommunity::Util
  
  has_many :records, :class_name => "VoteRecord", :foreign_key => "vote_topic_id", :dependent => :destroy
  has_many :options, :class_name => "VoteOption", :foreign_key => "vote_topic_id", :dependent => :destroy
  
  has_many :comments, :class_name => "VoteComment", :foreign_key => "vote_topic_id", :dependent => :destroy
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  belongs_to :category, :class_name => "VoteCategory", :foreign_key => "category_id"
  
  has_one :image, :class_name => "VoteImage", :foreign_key => "vote_topic_id", :dependent => :destroy
  
  
  validates_presence_of :account_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :category_id, :message => "请选择 分类"
  
  validates_length_of :title, :maximum => 256, :message => "标题 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "描述 超过长度限制", :allow_nil => true
  
  
  
  named_scope :global, :conditions => ["group_id = ? or group_id = ?", 0, nil]
  
  
  
  CKP_vote_topic_with_img = :vote_topic_with_img
  
  CKP_vote_invitations = :vote_invitations
  CKP_vote_contact_invitations = :vote_contact_invitations
  
  FCKP_spaces_show_vote_topic = :fc_spaces_show_vote_topic
  FCKP_votes_show_created_vote_topic = :fc_votes_show_created_vote_topic
  
  FCKP_index_vote_topic = :fc_index_vote_topic
  FCKP_community_index_vote_topic = :fc_community_index_vote_topic
  
  after_save { |vote_topic|
    self.clear_spaces_show_vote_topic_cache(vote_topic.account_id)
    self.clear_votes_show_created_vote_topic_cache(vote_topic.account_id)
    
    self.clear_index_vote_topic_cache
    self.clear_community_index_vote_topic_cache
  }
  
  after_destroy { |vote_topic|
    self.clear_vote_with_image_cache(vote_topic.id)
    
    
    self.clear_spaces_show_vote_topic_cache(vote_topic.account_id)
    self.clear_votes_show_created_vote_topic_cache(vote_topic.account_id)
    
    self.clear_index_vote_topic_cache
    self.clear_community_index_vote_topic_cache
    
    PointProfile.adjust_account_points_by_action(vote_topic.account_id, :add_vote_topic, false)
  }
  
  after_create { |vote_topic|
    PointProfile.adjust_account_points_by_action(vote_topic.account_id, :add_vote_topic, true)
  }
  
  def self.clear_spaces_show_vote_topic_cache(account_id)
    Cache.delete(expand_cache_key("#{FCKP_spaces_show_vote_topic}_#{account_id}"))
  end
  
  def self.clear_votes_show_created_vote_topic_cache(account_id)
    Cache.delete(expand_cache_key("#{FCKP_votes_show_created_vote_topic}_#{account_id}"))
  end
  
  def self.clear_index_vote_topic_cache
    Cache.delete(expand_cache_key(FCKP_index_vote_topic))
  end
  
  def self.clear_community_index_vote_topic_cache
    Cache.delete(expand_cache_key(FCKP_community_index_vote_topic))
  end
  
  
  
  def get_image_url
    vote_image = self.image
    vote_image && Photo.get_photo(vote_image.photo_id).image.url(:thumb_48)
  end
  
  def self.get_vote_topic_with_image(vote_topic_id)
    v_i = Cache.get("#{CKP_vote_topic_with_img}_#{vote_topic_id}".to_sym)
    
    unless v_i
      vote_topic = self.find(vote_topic_id)
      vote_image = vote_topic.get_image_url
      v_i = [vote_topic.clear_association, vote_image]
      
      Cache.set("#{CKP_vote_topic_with_img}_#{vote_topic_id}".to_sym, v_i, Cache_TTL)
    end
    v_i
  end
  
  def self.update_vote_topic_with_image_cache(vote_topic_id, updates = {})
    v_i = Cache.get("#{CKP_vote_topic_with_img}_#{vote_topic_id}".to_sym)
    if v_i
      if updates.key?(:vote_topic)
        vote_topic = updates[:vote_topic]
        v_i[0] = vote_topic.clear_association
      end
      v_i[1] = updates[:vote_img] if updates.key?(:vote_img)
      Cache.set("#{CKP_vote_topic_with_img}_#{vote_topic_id}".to_sym, v_i, Cache_TTL)
    end
  end
  
  def self.set_vote_topic_with_image_cache(vote_topic_id, vote_topic, vote_img_url)
    v_i = [vote_topic.clear_association, vote_img_url]
    Cache.set("#{CKP_vote_topic_with_img}_#{vote_topic_id}".to_sym, v_i, Cache_TTL)
  end
  
  def self.clear_vote_with_image_cache(vote_topic_id)
    Cache.delete("#{CKP_vote_topic_with_img}_#{vote_topic_id}".to_sym)
  end
  
  
  def calculate_chart_height(height_of_one_option = 25)
    h = height_of_one_option * (VoteOption.get_vote_topic_options(self.id).size)
    h < 150 ? 150 : h
  end
  
  
  def self.get_vote_invitations
    Cache.get(CKP_vote_invitations) || []
  end
  
  def self.add_vote_invitation(invitation)
    invitations = get_vote_invitations
    invitations << invitation
    Cache.set(CKP_vote_invitations, invitations)
  end
  
  def self.clear_vote_invitations_cache
    Cache.delete(CKP_vote_invitations)
  end
  
  
  def self.get_vote_contact_invitations
    Cache.get(CKP_vote_contact_invitations) || []
  end
  
  def self.add_vote_contact_invitation(invitation)
    invitations = get_vote_contact_invitations
    invitations << invitation
    Cache.set(CKP_vote_contact_invitations, invitations)
  end
  
  def self.clear_vote_contact_invitations_cache
    Cache.delete(CKP_vote_contact_invitations)
  end
  
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end


