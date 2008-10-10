class IndexController < ApplicationController
  
  def index
    
    @display_activity_posts = [
      [" 上海中医药大学讲座", "/images/real_index/activity_posts/zhongyiyao_20081016.jpg", "/activities/1003"],
      ["望闻问切 把脉职场 - 成功求职的10个关键！", "/images/real_index/activity_posts/first_session_20081012.jpg", "/activities/1002"]
    ]

  end

  def noisy_image
    image = NoisyImage.new(4)
    session[:img_code] = image.code
    send_data(image.code_image, :type => "image/jpeg", :disposition => "inline")
  end
  
end
