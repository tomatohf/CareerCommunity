class IndexController < ApplicationController
  
  def index

  end

  def noisy_image
    image = NoisyImage.new(4)
    session[:img_code] = image.code
    send_data(image.code_image, :type => "image/jpeg", :disposition => "inline")
  end
  
end
