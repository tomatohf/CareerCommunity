class CustomGroups::FeedbackController < ApplicationController
  
  layout "community"
  
  

  def show
    render :text => "feedback group ..."
  end

end

