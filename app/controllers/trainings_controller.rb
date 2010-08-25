class TrainingsController < ApplicationController
  
  def index
    
  end
  
  
  def products
    @sub_pages = [
      ["recommend", "学员推荐课程"],
      ["list", "课程一览表"]
    ]
    prepare_sub_page
  end
  
  
  def featured
    @sub_pages = [
      ["sales", "专业销售技巧"],
      ["manage", "管理沟通类培训"],
      ["career", "职场提升训练"],
      ["outward", "拓展训练"]
    ]
    prepare_sub_page
  end
  
  
  def recent
    
  end
  
  
  def cases
    @sub_pages = [
      ["expo", "世博志愿者培训"],
      ["tiyan", "世博志愿者七彩体验营"],
      ["yili", "伊利世博项目门店销售培训"],
      ["pudong", "浦东新区团干部骨干培训班"],
      ["cangyuan", "沧源科技园区中小企业销售培训"]
    ]
    prepare_sub_page
  end
  
  
  def about
    
  end
  
  
  private
  
  def prepare_sub_page
    unless @sub_pages.blank?
      @sub_page = @sub_pages.detect{ |p| p[0] == params[:id] }
      jump_to("/trainings/#{action_name}/#{@sub_pages[0][0]}") unless @sub_page
    end
  end
  
end
