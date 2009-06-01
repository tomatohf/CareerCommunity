class CustomGroups::FeedbackController < CustomGroups::CustomGroupsController
  
  Group_Post_Num = 30
  
  Group_Vote_Num = 20
  

  def show
    # @group_id = params[:id]
    # @group, @group_image = Group.get_group_with_image(@group_id)
    
    # should NOT cache the relationship check
    @relationship = "logout"
    if has_login?
      if @group.master_id == session[:account_id]
        @relationship = "master"
      else
        is_member = GroupMember.is_group_member(@group_id, session[:account_id])
        @relationship = is_member ? (GroupMember.is_group_admin(@group_id, session[:account_id]) ? "admin" : "member") : "not_member"
      end
    end
    
    @group_setting = @group.get_setting
    
    @top_group_posts = GroupPost.find(
      :all,
      :select => "id, created_at, group_id, top, good, account_id, title, responded_at",
      :conditions => ["group_id = ? and top = ?", @group_id, true],
      :include => [:account],
      :order => "responded_at DESC"
    )
    
    @group_posts = GroupPost.find(
      :all,
      :limit => Group_Post_Num,
      :select => "id, created_at, group_id, top, good, account_id, title, responded_at",
      :conditions => ["group_id = ? and top = ?", @group_id, false],
      :include => [:account],
      :order => "responded_at DESC"
    )
  end
  
  
  private
  
  def self.check_compose_access(group_id, account_id)
    true
  end

end

