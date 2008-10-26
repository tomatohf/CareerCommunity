class VoteTopic < ActiveRecord::Base
  
  include CareerCommunity::Util
  
  has_many :records, :class_name => "VoteRecord", :foreign_key => "vote_topic_id", :dependent => :destroy
  has_many :options, :class_name => "VoteOption", :foreign_key => "vote_topic_id", :dependent => :destroy
  
  has_many :comments, :class_name => "VoteComment", :foreign_key => "vote_topic_id", :dependent => :destroy
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"
  
  has_one :image, :class_name => "VoteImage", :foreign_key => "vote_topic_id", :dependent => :destroy
  
  
  validates_presence_of :account_id
  
  validates_presence_of :title, :message => "请输入 标题"
  validates_presence_of :category_id, :message => "请选择 分类"
  
  validates_length_of :title, :maximum => 256, :message => "标题 超过长度限制", :allow_nil => false
  validates_length_of :desc, :maximum => 1000, :message => "描述 超过长度限制", :allow_nil => true
  
  
  
  CKP_vote_topic_with_img = :vote_topic_with_img
  
  after_destroy { |vote_topic|
    self.clear_vote_with_image_cache(vote_topic.id)
  }
  
  
  
  def get_image_url
    pic_url = self.image && self.image.pic_url
    
    unless Pathname.new("#{RAILS_ROOT}/public#{pic_url}").exist?
      pic_url = nil
      photo_id = self.image.photo_id
      if photo_id
        photo = Photo.find(photo_id)
        pic_url = photo.image.url(:thumb_48)
        self.image.pic_url = pic_url
        self.image.save
      else
        self.image.destroy
      end
    end
    pic_url
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
  
  
  
  def clear_association
    copy = deep_copy(self)
    copy.clear_association_cache
    copy.clear_aggregation_cache
    copy
  end
  
end

