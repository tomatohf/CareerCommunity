class FriendsController < ApplicationController
  
  Friend_Max_Count = 150
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  before_filter :check_login, :only => [:list_edit, :be_list_edit, :both_list_edit, :create, :destroy]
  before_filter :check_limited, :only => [:create, :destroy]
  
  before_filter :check_edit_for_friend, :only => [:list_edit, :be_list_edit, :both_list_edit]
  
  # ! current account needed !
  def index
    jump_to("/friends/list_edit/#{session[:account_id]}")
  end
  
  def create
    friend_id = params[:friend] && params[:friend].strip

    unless session[:account_id].to_s == friend_id
      # can not add self as friend ...
      unless Friend.is_friend(session[:account_id], friend_id)
        # has not been added as friend
        #if Account.exists?(friend_id)
          # the friend account exists
          
          friend_count = Friend.count_friend(session[:account_id])
          if friend_count < Friend_Max_Count
            friend = Friend.new(:account_id => session[:account_id])
            friend.friend_id = friend_id
            if friend.save
              AccountAction.create_new(session[:account_id], "add_friend", {
                :friend_id => friend_id
              })
              
              SysMessage.create_new(friend_id, "add_friend", {
                :account_id => session[:account_id]
              })
            end
          else
            # beyond the max friend count
            flash[:max_friend_count] = Friend_Max_Count
          end
        #end
      end
    end
    
    jump_to("/friends/list_edit/#{session[:account_id]}")
  end
  
  def destroy
    friend_id = params[:id]
    Friend.delete_all(["account_id = #{session[:account_id]} and friend_id = ?", friend_id])
    
    jump_to("/friends/list_edit/#{session[:account_id]}")
  end
  
  def list
    @owner_id = params[:id]
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    @friends = Friend.get_all_by_account(
      @owner_id,
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
  
  # ! login required !
  def list_edit
    @edit = true
    list
    render :action => "list"
  end
  
  def be_list
    @owner_id = params[:id]
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    @accounts = Friend.get_all_by_friend(
      @owner_id,
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    ).collect { |a|
      account_id = a.account.id
      account_nick = a.account.get_nick
      account_pic_url = a.account.get_profile_pic_url
      
      Account.set_account_nick_pic_cache(account_id, account_nick, account_pic_url, a.account.email)
      
      [account_nick, account_pic_url, a.account.email, account_id]
    }
  end
  
  # ! login required !
  def be_list_edit
    @edit = true
    be_list
    render :action => "be_list"
  end
  
  def both_list
    @owner_id = params[:id]
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    @friends = Friend.get_all_both_friends_by_account(
      @owner_id,
      "created_at DESC"
    ).collect { |f|
      account_id = f.friend.id
      account_nick = f.friend.get_nick
      account_pic_url = f.friend.get_profile_pic_url
      
      Account.set_account_nick_pic_cache(account_id, account_nick, account_pic_url, f.friend.email)
      
      [account_nick, account_pic_url, f.friend.email, account_id]
    }
  end
  
  # ! login required !
  def both_list_edit
    @edit = true
    both_list
    render :action => "both_list"
  end
  
  private
  
  def check_edit_for_friend
    jump_to("/friends/#{action_name[0...-5]}/#{params[:id]}") unless session[:account_id].to_s == params[:id]
  end
  
end