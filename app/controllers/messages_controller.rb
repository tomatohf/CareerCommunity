class MessagesController < ApplicationController
  
  Message_Page_Size = 10
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  before_filter :check_login, :only => [:inbox, :outbox, :sys, :thread, :compose, :create, :destroy,
                                        :choose_friend, :choose_be_friend, :create_reply,
                                        :summary]
  before_filter :check_limited, :only => [:create, :destroy, :create_reply]
  
  before_filter :check_message_access, :only => [:inbox, :outbox, :sys, :thread,
                                                  :choose_friend, :choose_be_friend,
                                                  :summary]
  before_filter :count_unread, :only => [:inbox, :outbox, :sys, :thread, :summary]
  
  # ! current account needed !
  def index
    jump_to("/messages/summary/#{session[:account_id]}")
  end
  
  def summary
    @account_id = params[:id]
  end
  
  def thread
    @account_id = params[:id]
    @other_id = params[:other_id]
    @reply_to_id = params[:reply_to_id]
    
    @messages = Message.get_threads(@account_id, @other_id, @reply_to_id) + SentMessage.get_threads(@account_id, @other_id, @reply_to_id)
    
    @messages.sort! {|x, y| x.created_at <=> y.created_at }
  end
  
  def choose_friend
    @account_id = params[:id]
    @info = "给我的朋友发消息"
    
    @friends = Friend.get_all_by_account(
      @account_id,
      :include => [:friend => [:profile_pic]],
      :order => "created_at DESC"
    ).collect { |f|
      account_id = f.friend.id
      account_nick = f.friend.get_nick
      account_pic_url = f.friend.get_profile_pic_url
      
      Account.set_account_nick_pic_cache(account_id, account_nick, account_pic_url, f.friend.email)
      
      [account_nick, account_pic_url, f.friend.email, account_id]
    }
  end
  
  def choose_be_friend
    @account_id = params[:id]
    @info = "给加我为朋友的人发消息"
    
    @friends = Friend.get_all_by_friend(
      @account_id,
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    ).collect { |a|
      account_id = a.account.id
      account_nick = a.account.get_nick
      account_pic_url = a.account.get_profile_pic_url
      
      Account.set_account_nick_pic_cache(account_id, account_nick, account_pic_url, a.account.email)
      
      [account_nick, account_pic_url, a.account.email, account_id]
    }
    
    render :action => "choose_friend"
  end
  
  def compose
    @account_id = params[:id]
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
  end
  
  def create
    receiver_id = params[:to]
    sender_id = session[:account_id].to_s
    
    if (sender_id != receiver_id) && Account.exists?(receiver_id)
      msg_content = params[:message_content] && params[:message_content].strip
      
      # add message to receiver's inbox
      msg = Message.new(:receiver_id => receiver_id, :sender_id => sender_id)
      msg.content = msg_content
      if msg.save
        # add message to sender's outbox
        sent_msg = SentMessage.new(
          :receiver_id => receiver_id,
          :sender_id => sender_id,
          :content => msg_content,
          :reply_to_id => msg.id
        )
        sent_msg.save
      end
    end
    
    jump_to("/messages/outbox/#{session[:account_id]}")
  end
  
  def create_reply
    reply_to_id = params[:id]
    receiver_id = params[:receiver_id]
    sender_id = session[:account_id].to_s
    
    if (sender_id != receiver_id) && Account.exists?(receiver_id)
      msg_content = params[:message_content] && params[:message_content].strip
      
      # add message to receiver's inbox
      msg = Message.new(
        :receiver_id => receiver_id,
        :sender_id => sender_id,
        :content => msg_content,
        :reply_to_id => reply_to_id
      )
      
      if msg.save
        # add message to sender's outbox
        sent_msg = SentMessage.new(
          :receiver_id => receiver_id,
          :sender_id => sender_id,
          :content => msg_content,
          :reply_to_id => reply_to_id
        )
        sent_msg.save
      end
    end
    
    jump_to("/messages/thread/#{sender_id}/#{receiver_id}/#{reply_to_id}#message_reply")
  end
  
  def inbox
    @account_id = params[:id]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @messages = Message.paginate(
      :page => page,
      :per_page => Message_Page_Size,
      :conditions => ["receiver_id = ?", @account_id],
      :include => [:sender => [:profile_pic]],
      :order => "created_at DESC"
    )
  end
  
  def outbox
    @account_id = params[:id]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @messages = SentMessage.paginate(
      :page => page,
      :per_page => Message_Page_Size,
      :conditions => ["sender_id = ?", @account_id],
      :include => [:receiver => [:profile_pic]],
      :order => "created_at DESC"
    )
  end
  
  def sys
    @account_id = params[:id]
    
    page = params[:page]
    page = 1 unless page =~ /\d+/
    @messages = SysMessage.paginate(
      :page => page,
      :per_page => Message_Page_Size,
      :conditions => ["account_id = ?", @account_id],
      :order => "created_at DESC"
    )
  end
  
  def destroy
    delete_sent = params[:d_s] == "true"
    if delete_sent
      message_class = "SentMessage"
      owner_attr = "sender_id"
      box = "outbox"
    else
      message_class = "Message"
      owner_attr = "receiver_id"
      box = "inbox"
    end
    
    eval(message_class).delete_all(["#{owner_attr} = #{session[:account_id]} and id = ?", params[:id]])
    jump_to("/messages/#{box}/#{session[:account_id]}")
  end
  
  private
  
  def check_message_access
    jump_to("/errors/forbidden") unless session[:account_id].to_s == params[:id]
  end
  
  def count_unread
    @unread_inbox_count = Message.get_unread_count(session[:account_id]) || 0
    @unread_sys_count = SysMessage.get_unread_count(session[:account_id]) || 0
  end
  
end