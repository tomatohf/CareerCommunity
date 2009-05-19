class ChatsController < ApplicationController
  
  
  Community_Channel_Name = "community"
  Public_Channel_Name = "public"
  
  
  layout "community"
  
  before_filter :check_current_account, :only => [:index, :to]
  before_filter :check_login, :only => [:group, :update_online_list, :update_online_friends, :show,
                                        :public, :update_public_chatroom_online_count]
  before_filter :check_limited, :only => []
  
  before_filter :check_group_access, :only => [:group]
  
  before_filter :check_account_access, :only => [:show]
  
  skip_before_filter :verify_authenticity_token, :only => [:subscription, :connection_logout]
  
  
  
  def subscription
    # session_id = params[:session_id]
    
    client_id = params[:client_id]
    channels = params[:channels] || []
    
    valid = (channels.size > 0)
    if valid
      channels.each do |channel|
        valid = if channel =~ /^(.*)_(\d+)$/
                  self.respond_to?("has_#{$1}_access", true) && self.send("has_#{$1}_access", $2, client_id)
                else
                  self.respond_to?("has_#{channel}_access", true) && self.send("has_#{channel}_access", client_id)
                end
        break unless valid
      end
    end
    
    render :nothing => true, :status => (valid ? 200 : 403)
  end
  
  def connection_logout
    # session_id = params[:session_id]
    
    client_id = params[:client_id]
    channels = params[:channels] || []
    
    client_nick_pic = Account.get_nick_and_pic(client_id)
    
    if channels.include?(Community_Channel_Name)
      unless ChatsController.helpers.online?(client_id)
        content = render_to_string :update do |page|
          page.call :remove_from_online_list, client_id
          page.call :insert_msg, client_id, 
            %Q!
              <div class="chat_sys_msg">
                系统通知:
                &nbsp;

                <a href="/spaces/show/#{client_id}" class="account_nick_link" target="_blank">
                  #{h(client_nick_pic[0])}</a>
                离线了

                &nbsp;
                <span class="chat_time">
                  (#{DateTime.now.strftime("%H:%M:%S")})
                </span>
              </div>
            !
        end
        Juggernaut.send_to_channel(content, channels)
      end
    else
      content = render_to_string :update do |page|
        page.call :remove_from_online_list, client_id
        page.insert_html :bottom, "chat_area", 
          %Q!
            <div class="chat_sys_msg">
              系统通知:
              &nbsp;
            
              <a href="#" class="account_nick_link" onclick="set_to_account('#{h(client_nick_pic[0])}'); return false;">
                #{h(client_nick_pic[0])}</a>
              离开了
            
              &nbsp;
              <span class="chat_time">
                (#{DateTime.now.strftime("%H:%M:%S")})
              </span>
            </div>
          !
        page.call :on_received_msg, client_id
      end
      Juggernaut.send_to_channel(content, channels)
    end
    
    render :nothing => true
  end
  
  
  
  def index
    jump_to("/chats/show/#{session[:account_id]}")
  end
  
  
  def update_online_list
    channels = params[:channels] || []
    client_id = session[:account_id].to_s
    
    client_nick_pic = Account.get_nick_and_pic(client_id)
    
    content = render_to_string :update do |page|
      page.replace_html "online_list_container",
                        :partial => "online_list",
                        :locals => {:channels => channels}      
      page.insert_html :bottom, "chat_area", 
        %Q!
          <div class="chat_sys_msg">
            系统通知:
            &nbsp;
            
            <a href="#" class="account_nick_link" onclick="set_to_account('#{h(client_nick_pic[0])}'); return false;">
              #{h(client_nick_pic[0])}</a>
            加入了
            
            &nbsp;
            <span class="chat_time">
              (#{DateTime.now.strftime("%H:%M:%S")})
            </span>
          </div>
        !
      page.call :on_received_msg, client_id
    end
    Juggernaut.send_to_channel(content, channels)
    
    render :nothing => true
  end
  
  def update_online_friends
    channels = [Community_Channel_Name]
    client_id = session[:account_id].to_s
    
    client_nick_pic = Account.get_nick_and_pic(client_id)
    
    html = render_to_string :partial => "online_friend", :locals => {:account_id => client_id, :account_nick => client_nick_pic[0], :account_img => client_nick_pic[1]}
    
    content = render_to_string :update do |page|
      page.call :add_online_friend, client_id, html
      
      page.call :insert_msg, client_id, 
        %Q!
          <div class="chat_sys_msg">
            系统通知:
            &nbsp;
            
            <a href="#" class="account_nick_link" onclick="set_to_account('#{h(client_nick_pic[0])}'); return false;">
              #{h(client_nick_pic[0])}</a>
            在线了
            
            &nbsp;
            <span class="chat_time">
              (#{DateTime.now.strftime("%H:%M:%S")})
            </span>
          </div>
        !
    end
    Juggernaut.send_to_clients_on_channels(
      content,
      Friend.get_account_be_friend_ids(client_id).collect { |a_id| a_id.to_s },
      channels
    )
    
    render :partial => "online_friend_list", :locals => {:friends => Friend.get_account_friend_ids(client_id)}
  end
  
  
  def group
    @channels = ["group_#{@group_id}"]
    
    if request.post?
      broadcast_chatroom_msg(session[:account_id].to_s, @channels)
      
      return render(:nothing => true)
    end
    
    
    @group, @group_image = Group.get_group_with_image(@group_id)
    @account_nick_pic = Account.get_nick_and_pic(session[:account_id])
  end
  
  def public
    @channels = [Public_Channel_Name]
    
    if request.post?
      broadcast_chatroom_msg(session[:account_id].to_s, @channels)
      
      return render(:nothing => true)
    end
    
    
    @account_nick_pic = Account.get_nick_and_pic(session[:account_id])
  end
  
  def show
    @channels = [Community_Channel_Name]
    
    if request.post?
      to_account_id = params[:to_account_id]
      msg = params[:chat_input] || ""
      
      msg_valid = validate_msg(msg)
      
      if msg_valid
        
        account_nick_pic = Account.get_nick_and_pic(@account_id)
        
        content = render_to_string :update do |page|
          page.call :insert_im_msg, to_account_id, @account_id, h(account_nick_pic[0]), face_img_src(account_nick_pic[1]), 
            %Q!
              <div>
                <span class="chat_time">
                  (#{DateTime.now.strftime("%H:%M:%S")})
                </span>
                <a href="/spaces/show/#{h(@account_id)}" class="account_nick_link" target="_blank">
                  #{h(params[:nick])}</a>
                :
                &nbsp;
                #{h(msg)}
              </div>
            !
        end
        Juggernaut.send_to_clients_on_channels(content, [@account_id, to_account_id], @channels)
      end
      
      return render(:nothing => true)
    end
    
    
    @account_nick_pic = Account.get_nick_and_pic(@account_id)
    
    @to_id = params[:to_id]
    if @to_id && @to_id != ""
      @to_nick_pic = Account.get_nick_and_pic(@to_id)
    end
  end
  
  def to
    jump_to("/chats/show/#{session[:account_id]}/to/#{params[:id]}")
  end
  
  def update_public_chatroom_online_count
    render :text => Juggernaut.show_clients_for_channels([Public_Channel_Name]).size, :layout => false
  end
  
  
  
  private
  
  def broadcast_chatroom_msg(sender_id, channels)
    msg = params[:chat_input] || ""
    
    msg_valid = validate_msg(msg)
    
    if msg_valid
      content = render_to_string :update do |page|
        page.insert_html :bottom, "chat_area", 
          %Q!
            <div>
              <span class="chat_time">
                (#{DateTime.now.strftime("%H:%M:%S")})
              </span>
              <a href="#" class="account_nick_link" onclick="set_to_account('#{h(params[:nick])}'); return false;">
                #{h(params[:nick])}</a>
              :
              &nbsp;
              #{h(msg)}
            </div>
          !
        page.call :on_received_msg, sender_id
      end
      Juggernaut.send_to_channel(content, channels)
    end
  end
  
  def check_account_access
    @account_id = params[:id]
    jump_to("/errors/forbidden") unless session[:account_id].to_s == @account_id
  end
  
  def validate_msg(msg)
    msg && (msg.strip != "") && msg.jsize <= 200
  end
  
  def check_group_access
    @group_id = params[:id]
    jump_to("/groups/#{@group_id}") unless has_group_access(@group_id, session[:account_id])
  end
  
  def has_group_access(group_id, account_id)
    GroupMember.is_group_member(group_id, account_id)
  end
  
  def has_community_access(account_id)
    true
  end
  
  def has_public_access(account_id)
    true
  end
  
end

