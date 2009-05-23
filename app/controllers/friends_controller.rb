class FriendsController < ApplicationController
  
  Friend_Max_Count = 150
  
  layout "community"
  before_filter :check_current_account, :only => [:index]
  before_filter :check_login, :only => [:create, :destroy]
  before_filter :check_limited, :only => [:create, :destroy]
  
  # ! current account needed !
  def index
    jump_to("/friends/list/#{session[:account_id]}")
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
    
    jump_to("/friends/list/#{session[:account_id]}")
  end
  
  def destroy
    friend_id = params[:id]
    Friend.find(:all, :conditions => ["account_id = #{session[:account_id]} and friend_id = ?", friend_id]).each do |f|
      f.destroy
    end
    
    jump_to("/friends/list/#{session[:account_id]}")
  end
  
  def list
    @owner_id = params[:id]
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    @edit = (session[:account_id].to_s == @owner_id)
    
    @friends = Friend.get_account_friend_ids(@owner_id).reverse.collect { |account_id|
      Account.get_nick_and_pic(account_id) << account_id
    }
  end
  
  def be_list
    @owner_id = params[:id]
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    @edit = (session[:account_id].to_s == @owner_id)
    
    @accounts = Friend.get_account_be_friend_ids(@owner_id).reverse.collect { |account_id|
      Account.get_nick_and_pic(account_id) << account_id
    }
  end
  
  def both_list
    @owner_id = params[:id]
    @owner_nick_pic = Account.get_nick_and_pic(@owner_id) unless @edit
    
    @edit = (session[:account_id].to_s == @owner_id)
    
    @friends = Friend.get_all_both_friends_by_account(@owner_id).reverse.collect { |account_id|
      Account.get_nick_and_pic(account_id) << account_id
    }
  end
  
  private

  
end