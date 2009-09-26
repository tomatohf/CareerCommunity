class CustomGroups::CustomGroupsController < GroupsController
  
  # skip not needed filters
  skip_before_filter [:check_custom_group]
  
  # make all groups controller actions private, to avoid being visited
  private(*(public_instance_methods - superclass.superclass.public_instance_methods))
  
  # check if it's a REAL custom group
  before_filter :check_group_type
  
  # where to find view template if it's not found under current controller directory
  def self.inherited_template_dir
    "groups"
  end
  
  
  
  private
  
  def check_group_type
    @group_id = params[:id]
    @group, @group_image = Group.get_group_with_image(@group_id)
    
    custom_key = @group.custom_key
    custom_group = custom_key && Group::Custom_Groups[custom_key]
    
    jump_to("/groups/#{@group_id}") unless controller_name == custom_group
  end
  
  
  # use groups_controller's view template if no custom_groups specific view template found ...
  alias_method :old_default_template_name, :default_template_name
  def default_template_name(action_name = self.action_name)
    template_name = old_default_template_name(action_name)
    (self.respond_to?(action_name, false) && !template_exists?(template_name)) ? "#{self.class.inherited_template_dir}/#{action_name}" : template_name
  end
  
  
  # Define template_exists? for Rails 2.3 (cause it's removed ...)
  unless ActionController::Base.private_instance_methods.include?("template_exists?")
    def template_exists?(path)
      self.view_paths.find_template(path, response.template.template_format)
    rescue ActionView::MissingTemplate
      false
    end
  end
  
end

