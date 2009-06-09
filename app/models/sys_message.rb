class SysMessage < ActiveRecord::Base
  
  acts_as_trashable
  
  
  include CareerCommunity::AccountBelongings
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id, :msg_type
  
  
  after_destroy { |sys_message|
    self.decrease_unread_count_cache(sys_message.account_id, 1) unless sys_message.has_read
  }
  
  after_create { |sys_message|
    self.increase_unread_count_cache(sys_message.account_id, 1)
  }
  
  
  CKP_unread_count = :sys_message_unread_count
  
  
  def self.get_unread_count(account_id)
    u_c = Cache.get("#{CKP_unread_count}_#{account_id}".to_sym)
    unless u_c
      u_c = self.count(:conditions => ["account_id = ? and has_read = ?", account_id, false])
      
      Cache.set("#{CKP_unread_count}_#{account_id}".to_sym, u_c, Cache_TTL)
    end
    u_c
  end
  
  def self.clear_unread_count_cache(account_id)
    Cache.delete("#{CKP_unread_count}_#{account_id}".to_sym)
  end
  
  def self.increase_unread_count_cache(account_id, count = 1)
    u_c = Cache.get("#{CKP_unread_count}_#{account_id}".to_sym)
    if u_c
      updated_u_c = u_c.to_i + count
      
      Cache.set("#{CKP_unread_count}_#{account_id}".to_sym, updated_u_c, Cache_TTL)
    end
  end
  
  def self.decrease_unread_count_cache(account_id, count = 1)
    u_c = Cache.get("#{CKP_unread_count}_#{account_id}".to_sym)
    if u_c
      updated_u_c = u_c.to_i - count
      
      Cache.set("#{CKP_unread_count}_#{account_id}".to_sym, updated_u_c, Cache_TTL)
    end
  end
  
  
  # define system message types
  
  Msg_Types = {
    "add_space_comment" => "添加留言",
    "add_friend" => "添加朋友",
    "join_group_request" => "加入圈子申请",
    "join_activity_request" => "报名参加活动申请",
    "approve_reject_join_group" => "批准/拒绝加入圈子",
    "approve_reject_join_activity" => "批准/拒绝参加活动",
    "invite_join_group" => "邀请加入圈子",
    "invite_join_activity" => "邀请参加活动",
    "deleted_from_activity" => "从活动中删除",
    "invite_join_vote" => "邀请参与投票",
    "adjust_point" => "调整积分"
  }
  
  Msg_Types.keys.each do |t|
    define_method(t) {
      t.to_s
    }
    
    define_method("#{t}_type") {
      type_class = t.to_s.split("_").collect{|str| str.capitalize }.join("")
      eval("Types::#{type_class}").instance
    }
  end
  
  
  def self.create_new(a_id, type_id, data)
    sm = self.new
    sm.msg_type = sm.send(type_id)
    sm.account_id = a_id
    sm.raw_data = sm.get_type_obj(type_id).build_raw_data(data)
    sm.save
  end
  
  def get_type_obj(type_id)
    self.send("#{type_id}_type")
  end
  
  def msg_text(owner_id)
    type_obj = get_type_obj(self.msg_type)
    type_obj.msg_text(type_obj.parse_raw_data(self.raw_data), owner_id)
  end
  
  
  module Types
    
    class Base
      include Singleton # use .instance() to return the single instance object
      
      def build_raw_data(data)
        data.kind_of?(String) ? data : data.inspect
      end
      
      def parse_raw_data(data)
        eval(data)
      end
      
    end
    
    class AddSpaceComment < Base
      def msg_text(data, owner_id)
        account_id = data[:account_id]
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        
        account_nick_pic = Account.get_nick_and_pic(account_id)
        account_nick = account_nick_pic[0]
        account_pic_url = account_nick_pic[1]
        
        %Q!
          render(:partial => "/messages/sys/add_space_comment", :locals => {
            :owner_id => #{owner_id},
            :account_id => #{account_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            :account_nick => #{account_nick.inspect},
            :account_pic_url => #{account_pic_url.inspect}
          })
        !
      end
    end
    
    class AddFriend < Base
      def msg_text(data, owner_id)
        account_id = data[:account_id]
        account_nick_pic = Account.get_nick_and_pic(account_id)
        account_nick = account_nick_pic[0]
        account_pic_url = account_nick_pic[1]
        
        not_friend = !Friend.is_friend(owner_id, account_id)
        
        %Q!
          render(:partial => "/messages/sys/add_friend", :locals => {
            :not_friend => #{not_friend},
            :account_id => #{account_id},
            :account_nick => #{account_nick.inspect},
            :account_pic_url => #{account_pic_url.inspect}
          })
        !
      end
    end
    
    class JoinGroupRequest < Base
      def msg_text(data, owner_id)
        requester_id = data[:requester_id]
        requester_nick_pic = Account.get_nick_and_pic(requester_id)
        requester_nick = requester_nick_pic[0]
        requester_pic_url = requester_nick_pic[1]
        
        group_id = data[:group_id]
        group, group_image = Group.get_group_with_image(group_id)
        
        message = data[:message] || ""
        
        %Q!
          render(:partial => "/messages/sys/join_group_request", :locals => {
            :requester_id => #{requester_id},
            :requester_nick => #{requester_nick.inspect},
            :requester_pic_url => #{requester_pic_url.inspect},
            
            :group_id => #{group_id},
            :group_name => #{group.name.inspect},
            :group_image => #{group_image.inspect},
            
            :message => #{message.inspect}
          })
        !
      end
    end
    
    class ApproveRejectJoinGroup < Base
      def msg_text(data, owner_id)
        admin_id = data[:admin_account_id]
        admin_nick_pic = Account.get_nick_and_pic(admin_id)
        admin_nick = admin_nick_pic[0]
        admin_pic_url = admin_nick_pic[1]
        
        group_id = data[:group_id]
        group, group_image = Group.get_group_with_image(group_id)
        
        approve = data[:approve]
        
        message = data[:message] || ""
        
        %Q!
          render(:partial => "/messages/sys/approve_reject_join_group", :locals => {
            :admin_id => #{admin_id},
            :admin_nick => #{admin_nick.inspect},
            :admin_pic_url => #{admin_pic_url.inspect},
            
            :group_id => #{group_id},
            :group_name => #{group.name.inspect},
            :group_image => #{group_image.inspect},
            
            :approve => #{approve},
            
            :message => #{message.inspect}
          })
        !
      end
    end
    
    class InviteJoinGroup < Base
      def msg_text(data, owner_id)
        inviter_id = data[:inviter_id]
        inviter_nick_pic = Account.get_nick_and_pic(inviter_id)
        inviter_nick = inviter_nick_pic[0]
        inviter_pic_url = inviter_nick_pic[1]
        
        group_id = data[:group_id]
        group, group_image = Group.get_group_with_image(group_id)
        
        invitation_words = data[:invitation_words]
        
        %Q!
          render(:partial => "/messages/sys/invite_join_group", :locals => {
            :inviter_id => #{inviter_id},
            :inviter_nick => #{inviter_nick.inspect},
            :inviter_pic_url => #{inviter_pic_url.inspect},
            
            :group_id => #{group_id},
            :group_name => #{group.name.inspect},
            :group_image => #{group_image.inspect},
            
            :invitation_words => #{invitation_words.inspect}
          })
        !
      end
    end
    
    class InviteJoinActivity < Base
      def msg_text(data, owner_id)
        inviter_id = data[:inviter_id]
        inviter_nick_pic = Account.get_nick_and_pic(inviter_id)
        inviter_nick = inviter_nick_pic[0]
        inviter_pic_url = inviter_nick_pic[1]
        
        activity_id = data[:activity_id]
        activity, activity_image = Activity.get_activity_with_image(activity_id)
        
        invitation_words = data[:invitation_words]
        
        %Q!
          render(:partial => "/messages/sys/invite_join_activity", :locals => {
            :inviter_id => #{inviter_id},
            :inviter_nick => #{inviter_nick.inspect},
            :inviter_pic_url => #{inviter_pic_url.inspect},
            
            :activity_id => #{activity_id},
            :activity_title => #{activity.get_title.inspect},
            :activity_image => #{activity_image.inspect},
            
            :invitation_words => #{invitation_words.inspect}
          })
        !
      end
    end
    
    class JoinActivityRequest < Base
      def msg_text(data, owner_id)
        requester_id = data[:requester_id]
        requester_nick_pic = Account.get_nick_and_pic(requester_id)
        requester_nick = requester_nick_pic[0]
        requester_pic_url = requester_nick_pic[1]
        
        activity_id = data[:activity_id]
        activity, activity_image = Activity.get_activity_with_image(activity_id)
        
        message = data[:message] || ""
        
        %Q!
          render(:partial => "/messages/sys/join_activity_request", :locals => {
            :requester_id => #{requester_id},
            :requester_nick => #{requester_nick.inspect},
            :requester_pic_url => #{requester_pic_url.inspect},
            
            :activity_id => #{activity_id},
            :activity_title => #{activity.get_title.inspect},
            :activity_image => #{activity_image.inspect},
            
            :message => #{message.inspect}
          })
        !
      end
    end
    
    class DeletedFromActivity < Base
      def msg_text(data, owner_id)
        activity_id = data[:activity_id]
        activity, activity_image = Activity.get_activity_with_image(activity_id)
        
        %Q!
          render(:partial => "/messages/sys/deleted_from_activity", :locals => {
            :activity_id => #{activity_id},
            :activity_title => #{activity.get_title.inspect},
            :activity_image => #{activity_image.inspect}
          })
        !
      end
    end
    
    class ApproveRejectJoinActivity < Base
      def msg_text(data, owner_id)
        admin_id = data[:admin_account_id] || data[:master_account_id]
        admin_nick_pic = Account.get_nick_and_pic(admin_id)
        admin_nick = admin_nick_pic[0]
        admin_pic_url = admin_nick_pic[1]
        
        activity_id = data[:activity_id]
        activity, activity_image = Activity.get_activity_with_image(activity_id)
        
        approve = data[:approve]
        
        message = data[:message] || ""
        
        %Q!
          render(:partial => "/messages/sys/approve_reject_join_activity", :locals => {
            :admin_id => #{admin_id},
            :admin_nick => #{admin_nick.inspect},
            :admin_pic_url => #{admin_pic_url.inspect},
            
            :activity_id => #{activity_id},
            :activity_title => #{activity.get_title.inspect},
            :activity_image => #{activity_image.inspect},
            
            :approve => #{approve},
            
            :message => #{message.inspect}
          })
        !
      end
    end
    
    class InviteJoinVote < Base
      def msg_text(data, owner_id)
        inviter_id = data[:inviter_id]
        inviter_nick_pic = Account.get_nick_and_pic(inviter_id)
        inviter_nick = inviter_nick_pic[0]
        inviter_pic_url = inviter_nick_pic[1]
        
        vote_topic_id = data[:vote_topic_id]
        vote_topic, vote_topic_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
        
        invitation_words = data[:invitation_words]
        
        %Q!
          render(:partial => "/messages/sys/invite_join_vote", :locals => {
            :inviter_id => #{inviter_id},
            :inviter_nick => #{inviter_nick.inspect},
            :inviter_pic_url => #{inviter_pic_url.inspect},
            
            :vote_topic_id => #{vote_topic_id},
            :vote_topic_title => #{vote_topic.title.inspect},
            :vote_topic_image => #{vote_topic_image.inspect},
            
            :invitation_words => #{invitation_words.inspect}
          })
        !
      end
    end
    
    class AdjustPoint < Base
      def msg_text(data, owner_id)
        points = data[:points]
        reason = data[:reason]
        
        %Q!
          render(:partial => "/messages/sys/adjust_point", :locals => {
            :points => #{points},
            :reason => #{reason.inspect}
          })
        !
      end
    end
    
  end
  
end
