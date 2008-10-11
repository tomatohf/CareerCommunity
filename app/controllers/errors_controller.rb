class ErrorsController < ApplicationController
  
  def limited
    
  end
  
  def forbidden
    
  end
  
  def unauthorized
    
  end
  
  # --- to override the default rails error pages: 500.html, 422.html, 404.html
  def status
    @code = params[:id]
    
    # default to render status 500 page
  end
  
end