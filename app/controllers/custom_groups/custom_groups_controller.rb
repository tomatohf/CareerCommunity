class CustomGroups::CustomGroupsController < GroupsController
  
  # skip all filters
  skip_filter filter_chain
  
  # make all groups controller actions private, to avoid being visited
  private(*(public_instance_methods - superclass.superclass.public_instance_methods))
  
  # check if it's a REAL custom group
  before_filter :check_group_type
  
  
  
  private
  
  def check_group_type
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    custom_key = @group.get_setting[:custom_key]
    custom_group = custom_key && Group::Custom_Groups[custom_key]
    
    jump_to("/groups/#{@group_id}") unless controller_name == custom_group
  end
  
end

