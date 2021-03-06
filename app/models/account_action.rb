class AccountAction < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id, :action_type
  
  
  
  named_scope :visible, :conditions => ["hide = ?", false]
  
  
  
  # define account action types
  
  @@action_types = {
    "add_space_comment" => "添加留言",
    "add_blog" => "发表博客",
    "add_blog_comment" => "评论博客",
    "add_friend" => "添加朋友",
    "join_group" => "加入圈子",
    "join_activity" => "参加活动",
    "add_group_post" => "发表圈子话题",
    "add_group_post_comment" => "回应圈子话题",
    "add_activity_post" => "发表活动话题",
    "add_activity_post_comment" => "回应活动话题",
    "create_vote_topic" => "发起投票",
    "join_vote_topic" => "参与投票",
    "add_vote_comment" => "评论投票",
    "add_bookmark" => "添加推荐/收藏",
    "add_talk_comment" => "评论访谈录",
    "add_job_service" => "添加求职服务",
    "evaluate_job_service" => "点评求职服务",
    "add_goal_post" => "发表目标话题",
    "add_goal_post_comment" => "回应目标话题",
    "add_goal" => "添加目标",
    "add_goal_track" => "添加目标进度",
    "add_goal_track_comment" => "评论目标进度",
    "add_career_test_result" => "参与测试",
    "add_company_post" => "发表公司讨论话题",
    "add_company_post_comment" => "回应公司讨论话题"
  }
  
  def self.action_types
    @@action_types
  end
  
  @@action_types.keys.each do |t|
    define_method(t) {
      t.to_s
    }
    
    define_method("#{t}_type") {
      type_class = t.to_s.split("_").collect{|str| str.capitalize }.join("")
      eval("Types::#{type_class}").instance
    }
  end
  
  
  def self.create_new(a_id, type_id, data)
    account_setting = AccountSetting.get_account_setting(a_id)
    hide = account_setting.get_setting_value("hide_action_#{type_id}".to_sym)
    
    aa = self.new
    aa.action_type = aa.send(type_id)
    aa.account_id = a_id
    aa.raw_data = aa.get_type_obj(type_id).build_raw_data(data)
    aa.hide = (hide == "true")
    aa.save
  end
  
  def get_type_obj(type_id)
    self.send("#{type_id}_type")
  end
  
  def action_text(operator, save_space = false)
    type_obj = get_type_obj(self.action_type)
    
    begin
      type_obj.action_text(type_obj.parse_raw_data(self.raw_data), %Q!["#{operator[0]}", "#{operator[1]}", #{operator[2]}]!, save_space)
    rescue Exception => e
	      ""
	  end
  end
  
  def render_info(save_space = false)
    type_obj = get_type_obj(self.action_type)
    
    begin
      type_obj.render_info(type_obj.parse_raw_data(self.raw_data), save_space)
    rescue Exception => e
	      nil
	  end
  end
  
  
  module Types
    
    class Base
      include Singleton # use .instance() to return the single instance object
      
      def build_raw_data(data = "")
        # data.kind_of?(String) ? data : data.inspect
        data.inspect
      end
      
      def parse_raw_data(data = "")
				eval(data)
      end
      
    end
    
    class AddSpaceComment < Base
      def action_text(data, operator, save_space)
        owner_id = data[:owner_id]
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        
        owner_nick_pic = Account.get_nick_and_pic(owner_id)
        owner_nick = owner_nick_pic[0]
        owner_pic_url = owner_nick_pic[1]
        
        %Q!
          render(:partial => "/spaces/actions/add_space_comment", :locals => {
            :operator => #{operator},
            :owner_id => #{owner_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            :owner_nick => #{owner_nick.inspect},
            :owner_pic_url => #{owner_pic_url.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        owner_id = data[:owner_id]
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        
        owner_nick_pic = Account.get_nick_and_pic(owner_id)
        owner_nick = owner_nick_pic[0]
        owner_pic_url = owner_nick_pic[1]
        
        [
          "add_space_comment",
          {
            :owner_id => owner_id,
            :comment_id => comment_id,
            :comment_content => comment_content,
            :owner_nick => owner_nick,
            :owner_pic_url => owner_pic_url,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddFriend < Base
      def action_text(data, operator, save_space)
        friend_id = data[:friend_id]
        friend_nick_pic = Account.get_nick_and_pic(friend_id)
        friend_nick = friend_nick_pic[0]
        friend_pic_url = friend_nick_pic[1]
        
        %Q!
          render(:partial => "/spaces/actions/add_friend", :locals => {
            :operator => #{operator},
            :friend_id => #{friend_id},
            :friend_nick => #{friend_nick.inspect},
            :friend_pic_url => #{friend_pic_url.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        friend_id = data[:friend_id]
        friend_nick_pic = Account.get_nick_and_pic(friend_id)
        friend_nick = friend_nick_pic[0]
        friend_pic_url = friend_nick_pic[1]
        
        [
          "add_friend",
          {
            :friend_id => friend_id,
            :friend_nick => friend_nick,
            :friend_pic_url => friend_pic_url,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class JoinGroup < Base
      def action_text(data, operator, save_space)
        group_id = data[:group_id]
        group, group_image = Group.get_group_with_image(group_id)
        
        %Q!
          render(:partial => "/spaces/actions/join_group", :locals => {
            :operator => #{operator},
            :group_id => #{group_id},
            :group_name => #{group.name.inspect},
            :group_image => #{group_image.inspect},
            :creator_id => #{group.creator_id},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        group_id = data[:group_id]
        group, group_image = Group.get_group_with_image(group_id)
        
        [
          "join_group",
          {
            :group_id => group_id,
            :group_name => group.name,
            :group_image => group_image,
            :creator_id => group.creator_id,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class JoinActivity < Base
      def action_text(data, operator, save_space)
        activity_id = data[:activity_id]
        
        begin
          activity, activity_image = Activity.get_activity_with_image(activity_id)
          
          activity_title = activity.get_title
          activity_creator_id = activity.creator_id
        rescue
          activity_title ||= ""
          
          # the creator_id will be -1 if the activity does not exist
          activity_creator_id ||= -1
          
        end
        
        activity_deleted = activity.nil?
        
        %Q!
          render(:partial => "/spaces/actions/join_activity", :locals => {
            :operator => #{operator},
            :activity_id => #{activity_id},
            :activity_title => #{activity_title.inspect},
            :activity_image => #{activity_image.inspect},
            :creator_id => #{activity_creator_id},
            :activity_deleted => #{activity_deleted},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        activity_id = data[:activity_id]
        
        begin
          activity, activity_image = Activity.get_activity_with_image(activity_id)
          
          activity_title = activity.get_title
          activity_creator_id = activity.creator_id
        rescue
          activity_title ||= ""
          
          # the creator_id will be -1 if the activity does not exist
          activity_creator_id ||= -1
          
        end
        
        activity_deleted = activity.nil?
        
        [
          "join_activity",
          {
            :activity_id => activity_id,
            :activity_title => activity_title,
            :activity_image => activity_image,
            :creator_id => activity_creator_id,
            :activity_deleted => activity_deleted,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class CreateVoteTopic < Base
      def action_text(data, operator, save_space)
        vote_topic_id = data[:vote_topic_id]
        
        begin
          vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
          
          vote_topic_title = vote_topic.title
        rescue
          vote_topic_title ||= ""
        end
        
        vote_topic_deleted = vote_topic.nil?
        
        %Q!
          render(:partial => "/spaces/actions/create_vote_topic", :locals => {
            :operator => #{operator},
            :vote_topic_id => #{vote_topic_id},
            :vote_topic_title => #{vote_topic_title.inspect},
            :vote_image => #{vote_image.inspect},
            :vote_topic_deleted => #{vote_topic_deleted},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        vote_topic_id = data[:vote_topic_id]
        
        begin
          vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
          
          vote_topic_title = vote_topic.title
        rescue
          vote_topic_title ||= ""
        end
        
        vote_topic_deleted = vote_topic.nil?
        
        [
          "create_vote_topic",
          {
            :vote_topic_id => vote_topic_id,
            :vote_topic_title => vote_topic_title,
            :vote_image => vote_image,
            :vote_topic_deleted => vote_topic_deleted,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class JoinVoteTopic < Base
      def action_text(data, operator, save_space)
        vote_topic_id = data[:vote_topic_id]
        
        begin
          vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
          
          vote_topic_title = vote_topic.title
        rescue
          vote_topic_title ||= ""
        end
        
        vote_topic_deleted = vote_topic.nil?
        
        %Q!
          render(:partial => "/spaces/actions/join_vote_topic", :locals => {
            :operator => #{operator},
            :vote_topic_id => #{vote_topic_id},
            :vote_topic_title => #{vote_topic_title.inspect},
            :vote_image => #{vote_image.inspect},
            :vote_topic_deleted => #{vote_topic_deleted},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        vote_topic_id = data[:vote_topic_id]
        
        begin
          vote_topic, vote_image = VoteTopic.get_vote_topic_with_image(vote_topic_id)
          
          vote_topic_title = vote_topic.title
        rescue
          vote_topic_title ||= ""
        end
        
        vote_topic_deleted = vote_topic.nil?
        
        [
          "join_vote_topic",
          {
            :vote_topic_id => vote_topic_id,
            :vote_topic_title => vote_topic_title,
            :vote_image => vote_image,
            :vote_topic_deleted => vote_topic_deleted,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddBlog < Base
      def action_text(data, operator, save_space)
        blog_id = data[:blog_id]
        blog_title = data[:blog_title]
        
        %Q!
          render(:partial => "/spaces/actions/add_blog", :locals => {
            :operator => #{operator},
            :blog_id => #{blog_id},
            :blog_title => #{blog_title.inspect},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        blog_id = data[:blog_id]
        blog_title = data[:blog_title]
        
        [
          "add_blog",
          {
            :blog_id => blog_id,
            :blog_title => blog_title,
          
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddBlogComment < Base
      def action_text(data, operator, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        blog_id = data[:blog_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_blog_comment", :locals => {
            :operator => #{operator},
            :blog_id => #{blog_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        blog_id = data[:blog_id]
        
        [
          "add_blog_comment",
          {
            :blog_id => blog_id,
            :comment_id => comment_id,
            :comment_content => comment_content,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddBookmark < Base
      def action_text(data, operator, save_space)
        bookmark_class_name = data[:bookmark_class_name]
        bookmark_id = data[:bookmark_id]
        bookmark_title = data[:bookmark_title]
        bookmark_url = data[:bookmark_url]
        bookmark_desc = data[:bookmark_desc]
        
        %Q!
          render(:partial => "/spaces/actions/add_bookmark", :locals => {
            :operator => #{operator},
            :bookmark_class_name => #{bookmark_class_name.inspect},
            :bookmark_id => #{bookmark_id},
            :bookmark_title => #{bookmark_title.inspect},
            :bookmark_url => #{bookmark_url.inspect},
            :bookmark_desc => #{bookmark_desc.inspect},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        bookmark_class_name = data[:bookmark_class_name]
        bookmark_id = data[:bookmark_id]
        bookmark_title = data[:bookmark_title]
        bookmark_url = data[:bookmark_url]
        bookmark_desc = data[:bookmark_desc]
        
        [
          "add_bookmark",
          {
            :bookmark_class_name => bookmark_class_name,
            :bookmark_id => bookmark_id,
            :bookmark_title => bookmark_title,
            :bookmark_url => bookmark_url,
            :bookmark_desc => bookmark_desc,
          
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddGroupPost < Base
      def action_text(data, operator, save_space)
        post_id = data[:post_id]
        post_title = data[:post_title]
        group_id = data[:group_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_group_post", :locals => {
            :operator => #{operator},
            :post_id => #{post_id},
            :post_title => #{post_title.inspect},
            :group_id => #{group_id},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        post_id = data[:post_id]
        post_title = data[:post_title]
        group_id = data[:group_id]
        
        [
          "add_group_post",
          {
            :post_id => post_id,
            :post_title => post_title,
            :group_id => group_id,
          
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddActivityPost < Base
      def action_text(data, operator, save_space)
        post_id = data[:post_id]
        post_title = data[:post_title]
        activity_id = data[:activity_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_activity_post", :locals => {
            :operator => #{operator},
            :post_id => #{post_id},
            :post_title => #{post_title.inspect},
            :activity_id => #{activity_id},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        post_id = data[:post_id]
        post_title = data[:post_title]
        activity_id = data[:activity_id]
        
        [
          "add_activity_post",
          {
            :post_id => post_id,
            :post_title => post_title,
            :activity_id => activity_id,
          
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddVoteComment < Base
      def action_text(data, operator, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        vote_topic_id = data[:vote_topic_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_vote_comment", :locals => {
            :operator => #{operator},
            :vote_topic_id => #{vote_topic_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        vote_topic_id = data[:vote_topic_id]
        
        [
          "add_vote_comment",
          {
            :vote_topic_id => vote_topic_id,
            :comment_id => comment_id,
            :comment_content => comment_content,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddGroupPostComment < Base
      def action_text(data, operator, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        group_post_id = data[:group_post_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_group_post_comment", :locals => {
            :operator => #{operator},
            :group_post_id => #{group_post_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        group_post_id = data[:group_post_id]
        
        [
          "add_group_post_comment",
          {
            :group_post_id => group_post_id,
            :comment_id => comment_id,
            :comment_content => comment_content,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddActivityPostComment < Base
      def action_text(data, operator, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        activity_post_id = data[:activity_post_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_activity_post_comment", :locals => {
            :operator => #{operator},
            :activity_post_id => #{activity_post_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        activity_post_id = data[:activity_post_id]
        
        [
          "add_activity_post_comment",
          {
            :activity_post_id => activity_post_id,
            :comment_id => comment_id,
            :comment_content => comment_content,
            
            :save_space => save_space
          }
        ]
      end
    end

    class AddTalkComment < Base
      def action_text(data, operator, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        talk_id = data[:talk_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_talk_comment", :locals => {
            :operator => #{operator},
            :talk_id => #{talk_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        talk_id = data[:talk_id]
        
        [
          "add_talk_comment",
          {
            :talk_id => talk_id,
            :comment_id => comment_id,
            :comment_content => comment_content,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddJobService < Base
      def action_text(data, operator, save_space)
        job_service_id = data[:job_service_id]
        job_service_name = data[:job_service_name]
        
        %Q!
          render(:partial => "/spaces/actions/add_job_service", :locals => {
            :operator => #{operator},
            :job_service_id => #{job_service_id},
            :job_service_name => #{job_service_name.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        job_service_id = data[:job_service_id]
        job_service_name = data[:job_service_name]
        
        [
          "add_job_service",
          {
            :job_service_id => job_service_id,
            :job_service_name => job_service_name,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class EvaluateJobService < Base
      def action_text(data, operator, save_space)
        evaluation_id = data[:evaluation_id]
        evaluation_content = data[:evaluation_content]
        evaluation_point = data[:evaluation_point]
        job_service_id = data[:job_service_id]
        
        %Q!
          render(:partial => "/spaces/actions/evaluate_job_service", :locals => {
            :operator => #{operator},
            :job_service_id => #{job_service_id},
            :evaluation_id => #{evaluation_id},
            :evaluation_point => #{evaluation_point},
            :evaluation_content => #{evaluation_content.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        evaluation_id = data[:evaluation_id]
        evaluation_content = data[:evaluation_content]
        evaluation_point = data[:evaluation_point]
        job_service_id = data[:job_service_id]
        
        [
          "evaluate_job_service",
          {
            :job_service_id => job_service_id,
            :evaluation_id => evaluation_id,
            :evaluation_point => evaluation_point,
            :evaluation_content => evaluation_content,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddGoalPost < Base
      def action_text(data, operator, save_space)
        post_id = data[:post_id]
        post_title = data[:post_title]
        goal_id = data[:goal_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_goal_post", :locals => {
            :operator => #{operator},
            :post_id => #{post_id},
            :post_title => #{post_title.inspect},
            :goal_id => #{goal_id},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        post_id = data[:post_id]
        post_title = data[:post_title]
        goal_id = data[:goal_id]
        
        [
          "add_goal_post",
          {
            :post_id => post_id,
            :post_title => post_title,
            :goal_id => goal_id,
          
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddGoalPostComment < Base
      def action_text(data, operator, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        goal_post_id = data[:goal_post_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_goal_post_comment", :locals => {
            :operator => #{operator},
            :goal_post_id => #{goal_post_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        goal_post_id = data[:goal_post_id]
        
        [
          "add_goal_post_comment",
          {
            :goal_post_id => goal_post_id,
            :comment_id => comment_id,
            :comment_content => comment_content,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddGoalTrack < Base
      def action_text(data, operator, save_space)
        track_id = data[:track_id]
        track_value = data[:track_value]
        track_desc = data[:track_desc]
        
        goal_follow_id = data[:goal_follow_id]
        goal_id = data[:goal_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_goal_track", :locals => {
            :operator => #{operator},
            :goal_id => #{goal_id},
            :goal_follow_id => #{goal_follow_id},
            :track_id => #{track_id},
            :track_value => #{track_value},
            :track_desc => #{track_desc.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        track_id = data[:track_id]
        track_value = data[:track_value]
        track_desc = data[:track_desc]
        
        goal_follow_id = data[:goal_follow_id]
        goal_id = data[:goal_id]
        
        [
          "add_goal_track",
          {
            :goal_id => goal_id,
            :goal_follow_id => goal_follow_id,
            :track_id => track_id,
            :track_value => track_value,
            :track_desc => track_desc,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddGoalTrackComment < Base
      def action_text(data, operator, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        track_id = data[:track_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_goal_track_comment", :locals => {
            :operator => #{operator},
            :track_id => #{track_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        track_id = data[:track_id]
        
        [
          "add_goal_track_comment",
          {
            :track_id => track_id,
            :comment_id => comment_id,
            :comment_content => comment_content,
            
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddGoal < Base
      def action_text(data, operator, save_space)
        goal_id = data[:goal_id]
        goal_name = data[:goal_name]
        
        %Q!
          render(:partial => "/spaces/actions/add_goal", :locals => {
            :operator => #{operator},
            :goal_id => #{goal_id},
            :goal_name => #{goal_name.inspect},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        goal_id = data[:goal_id]
        goal_name = data[:goal_name]
        
        [
          "add_goal",
          {
            :goal_id => goal_id,
            :goal_name => goal_name,
          
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddCareerTestResult < Base
      def action_text(data, operator, save_space)
        career_test_id = data[:career_test_id]
        career_test_name = CareerTest.get_test(career_test_id).name
        
        %Q!
          render(:partial => "/spaces/actions/add_career_test_result", :locals => {
            :operator => #{operator},
            :career_test_id => #{career_test_id},
            :career_test_name => #{career_test_name.inspect},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        career_test_id = data[:career_test_id]
        career_test_name = CareerTest.get_test(career_test_id).name
        
        [
          "add_career_test_result",
          {
            :career_test_id => career_test_id,
            :career_test_name => career_test_name,
          
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddCompanyPost < Base
      def action_text(data, operator, save_space)
        post_id = data[:post_id]
        post_title = data[:post_title]
        company_id = data[:company_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_company_post", :locals => {
            :operator => #{operator},
            :post_id => #{post_id},
            :post_title => #{post_title.inspect},
            :company_id => #{company_id},
          
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        post_id = data[:post_id]
        post_title = data[:post_title]
        company_id = data[:company_id]
        
        [
          "add_company_post",
          {
            :post_id => post_id,
            :post_title => post_title,
            :company_id => company_id,
          
            :save_space => save_space
          }
        ]
      end
    end
    
    class AddCompanyPostComment < Base
      def action_text(data, operator, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        company_post_id = data[:company_post_id]
        
        %Q!
          render(:partial => "/spaces/actions/add_company_post_comment", :locals => {
            :operator => #{operator},
            :company_post_id => #{company_post_id},
            :comment_id => #{comment_id},
            :comment_content => #{comment_content.inspect},
            
            :save_space => #{save_space.inspect}
          })
        !
      end
      
      def render_info(data, save_space)
        comment_id = data[:comment_id]
        comment_content = data[:comment_content]
        company_post_id = data[:company_post_id]
        
        [
          "add_company_post_comment",
          {
            :company_post_id => company_post_id,
            :comment_id => comment_id,
            :comment_content => comment_content,
            
            :save_space => save_space
          }
        ]
      end
    end
    
  end

end
