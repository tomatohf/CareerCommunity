class TrainingsController < ApplicationController
  
  def index
    
  end
  
  
  def products
    @grids = [
      ["recommend", "学员推荐课程"],
      ["list", "课程一览表"]
    ]
    
    @grid = @grids.detect{ |c| c[0] == params[:id] }
    return jump_to("/trainings/#{action_name}/#{@grids[0][0]}") unless @grid
  end
  
  
  def featured
    
  end
  
  
  def recent
    
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
    return jump_to("/trainings/#{action_name}/#{@cases[0][0]}") unless @case
  end
  
  
  def about
    
  end
  
end
