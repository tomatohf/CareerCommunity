class ErrorsController < ApplicationController
  
  def limited
    
  end
  
  def forbidden
    render :status => 403
  end
  
  def unauthorized
    render :status => 401
  end
  
  # --- to override the default rails error pages: 500.html, 422.html, 404.html
  def status
    @code = params[:id] || "500"
    
    # default to render status 500 page
    render :status => @code
  end
  
end