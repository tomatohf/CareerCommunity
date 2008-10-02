class ToolkitsController < ApplicationController
  
  include CareerCommunity::Util
  
  layout "community"
  
  def index

  end

  def astrology
    return if request.get?
    
    a_name = params[:a_name]
    if a_name.nil? || a_name == ""
      month = params[:month]
      date = params[:date]
      begin
        date = DateTime.new(Astrology.default_year, month.to_i, date.to_i)
        @astrology = Astrology.find_by_date(date)
      rescue
        flash.now[:error_msg] = "日期不正确, 请重试 ..."
      end
    else
      @astrology = Astrology.find_by_name(a_name)
    end
    
    respond_to do |format|
      format.html # astrology.html.erb
      format.xml  { head :ok }
    end
  end
  
  def password_strength
    return if request.get?
    
    password = params[:password]
    @score = check_password_strength(password)[0]
    @label, @level = get_strength_info_from_score(@score)
    @color = @level == 3 ? "yellow" : @level > 3 ? "green" : "red"
  end
  
  private
  
  def get_strength_info_from_score(strength_score = 0)
    strength_label = "无密码"
    level = 0
    if strength_score > 0 && strength_score < 16
      strength_label = "很弱"
      level = 1
    elsif strength_score > 15 && strength_score < 25
      strength_label = "弱"
      level = 2
    elsif strength_score > 24 && strength_score < 35
      strength_label = "中等"
      level = 3
    elsif strength_score > 34 && strength_score < 45
      strength_label = "强"
      level = 4
    elsif strength_score > 44
      strength_label = "很强"
      level = 5
    end
    
    [strength_label, level]
  end
  
end
