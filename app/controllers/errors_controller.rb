class ErrorsController < ApplicationController
  
  def limited
    
  end
  
  def forbidden
    render :layout => true, :status => 403
  end
  
  def unauthorized
    render :layout => true, :status => 401
  end
  
  # --- to override the default rails error pages: 500.html, 422.html, 404.html
  def status
    @code = params[:id] || "500"
    
    # default to render status 500 page
    # 
    # lighttpd's bug that can not handle all kinds of status code, like 422
    # it will remove the page body ... so we just return status code 404 or 500
    render :layout => true, :status => (@code == "404") ? "404" : "500"
  end
  
end