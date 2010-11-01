class TrainingsController < ApplicationController
  
  Recent_Projects_Group = 36
  
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
    @page = params[:page].to_i
    @page = 1 unless @page > 0
    @posts = GroupPost.paginate(
      :page => @page,
      :per_page => 10,
      :select => "id, created_at, group_id, title, responded_at",
      :conditions => ["group_id = ?", Recent_Projects_Group],
      :order => "responded_at DESC"
    )
    return jump_to(%Q!/trainings/#{@page > 1 ? "recent" : "cases"}!) unless @posts.size > 0
    
    @post = GroupPost.get_post(params[:id].blank? ? @posts.first.id : params[:id])
    return jump_to("/trainings") unless @post.group_id == Recent_Projects_Group
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
