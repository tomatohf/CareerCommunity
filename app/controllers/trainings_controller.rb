class TrainingsController < ApplicationController
  
  def index
    
  end
  
  
  def cases
    @cases = [
      ["expo", "世博志愿者培训"],
      ["tiyan", "世博志愿者七彩体验营"],
      ["yili", "伊利世博项目门店销售培训"],
      ["pudong", "浦东新区团干部骨干培训班"],
      ["cangyuan", "沧源科技园区中小企业销售培训"]
    ]
    
    @case = @cases.detect{ |c| c[0] == params[:id] }
    return jump_to("/trainings/cases/expo") unless @case
  end
  
  
  def about
    
  end
  
end
