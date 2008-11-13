class IndexController < ApplicationController
  
  Index_Activity_Account_Id_Scope = [1002, 1004, 1019]
  
  Index_Group_Post_Group_Id_Scope = [2, 3, 4, 5, 7, 8]
  
  
  
  def index
    
  end

  def noisy_image
    image = NoisyImage.new(4)
    session[:img_code] = image.code
    send_data(image.code_image, :type => "image/jpeg", :disposition => "inline")
  end
  
  
  
  # ----------
  
  def pharm_campus_session
    render :layout => "campus_session"
  end
  
end
