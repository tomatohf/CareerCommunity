class ChatsController < ApplicationController
  
  
  layout "community"
  
  before_filter :check_login, :only => [:group, :update_online_list]
  before_filter :check_limited, :only => []
  
  before_filter :check_group_access, :only => [:group]
  
  skip_before_filter :verify_authenticity_token, :only => [:subscription, :connection_logout]
  
  
  
  def subscription
    # session_id = params[:session_id]
    
    client_id = params[:client_id]
    channels = params[:channels] || []
    
    valid = (channels.size > 0)
    if valid
      channels.each do |channel|
        valid = (channel =~ /^(.*)_(\d+)/) && self.respond_to?("has_#{$1}_access", true) && self.send("has_#{$1}_access", $2, client_id)
        break unless valid
      end
    end
    
    render :nothing => true, :status => (valid ? 200 : 403)
  end
  
  def connection_logout
    # session_id = params[:session_id]
    
    client_id = params[:client_id]
    channels = params[:channels]
    
    content = render_to_string :update do |page|
      page.call :remove_from_online_list, client_id
      page.insert_html :bottom, "chat_area", "<div>#{client_id} 离开了~</div>"
      #page.call :scrollChatPanel, 'chat_area'
    end
    Juggernaut.send_to_channel(content, channels)
    
    render :nothing => true
  end
  
  
  def update_online_list
    channels = params[:channels] || []
    client_id = session[:account_id].to_s
    
    content = render_to_string :update do |page|
      page.replace_html "online_list_container",
                        :partial => "online_list",
                        :locals => {:channels => channels}      
      page.insert_html :bottom, "chat_area", "<div>#{session[:account_id]} 加入了~</div>"
      #page.call :scrollChatPanel, 'chat_area'
    end
    Juggernaut.send_to_channel(content, channels)
    
    render :nothing => true
  end
  
  
  def group
    
    @channels = ["group_#{@group_id}"]
    
    if request.post?
      content = render_to_string :update do |page|
        page.insert_html :bottom, "chat_area", 
          %Q!
            <div>
              <span style="font-size: 10px;">
                (#{DateTime.now.strftime("%H:%M:%S")})
              </span>
              <a href="/spaces/show/#{session[:account_id]}" target="_blank" class="account_nick_link">
                #{h(params[:nick])}</a>
              :
              &nbsp;
              #{h(params[:chat_input])}
            </div>
          !
        #page.call :scrollChatPanel, 'chat_area'
      end
      
      Juggernaut.send_to_channel(content, @channels)
      
      return render(:nothing => true)
    end
    
    
    @group, @group_image = Group.get_group_with_image(@group_id)
    @account_nick_pic = Account.get_nick_and_pic(session[:account_id])
    
  end
  
  
  
  private
  
  def check_group_access
    @group_id = params[:id]
    jump_to("/groups/#{@group_id}") unless has_group_access(@group_id, session[:account_id])
  end
  
  def has_group_access(group_id, account_id)
    GroupMember.is_group_member(group_id, account_id)
  end
  
end

