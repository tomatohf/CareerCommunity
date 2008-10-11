# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def round_corner_div(attr = {}, &block)
    attr[:border_color] ||= "#A3988C"
    attr[:bg_color] ||= "#FAFFE7"
    concat(render(:partial => "common/round_corner_div", :locals => {:attr => attr, :content => capture(&block)}), block.binding)
  end
  
  def list_model_validate_errors(model)
    errors = ""
    model.errors.each do |attr, error|
      errors += "#{error}<br />"
    end
    errors
  end
  
  def draw_hor_line(long, width="1px", color="#B2B2B2", style="dashed")
    %Q{
      <div style="width: #{long} ; border-top-width: #{width} ; border-top-color: #{color} ; border-top-style: #{style}"></div>
    }
  end
  
  def thin_hr(color = "#EEEEEE")
    %Q{
      <hr size="1" style="color: #{color}" />
    }
  end
  
  def unchecked_alert(account_or_checked)
    checked = account_or_checked.kind_of?(Account) ? account_or_checked.checked : account_or_checked
    html = ""
    unless checked
      html = %Q{
        <div>
          <img src="/images/warning_small.png" border="0" alt="警告" title="警告" />
            你的注册 email 地址尚未得到验证, 你的帐号功能将受到限制, 不能进行任何更新操作。
            你可以试试
          <a href="/accounts/send_register_confirmation">重新发送注册确认邮件</a>
        </div>
      }
    end
    html
  end
  
  def province_select_options(provinces_info, selected_id = nil)
    options = %Q{<option value=""></option>}
    provinces_info.each { |p|
      options += %Q!<option value="#{p[0]}"#{selected_id == p[0] ? " selected=\"selected\"" : ""}>#{p[1]}</option>!
    }
    options
  end
  
  def format_datetime(datetime)
    datetime && datetime.strftime("%Y-%m-%d %H:%M:%S")
  end
  
  def format_date(date)
    date && date.strftime("%Y-%m-%d")
  end
  
  def format_activity_time(time)
    time && (time.strftime("%Y年%m月%d日") + " 星期#{["天","一","二","三","四","五","六"][time.wday]} " + time.strftime("%H:%M"))
  end
  
  def format_calendar_datetime(datetime)
    datetime && datetime.strftime("%Y-%m-%d %H:%M")
  end
  
  def face_img_src(src)
    (src && (src != "") && Pathname.new("#{RAILS_ROOT}/public#{src}").exist?) ? src : "/images/default_face.png"
  end
  
  def paging_buttons(collection)
    will_paginate(
      collection,
      :prev_label => "« 上一页",
      :next_label => "下一页 »",
      :param_name => :page, # parameter name for page number in URLs (default: :page)
      :page_links => true, # when false, only previous/next links are rendered (default: true) 
      # :separator => "", # string separator for page HTML elements (default: single space)
      # :inner_window => 4, # how many links are shown around the current page (default: 4)
      # :outer_window => 1, # how many links are around the first and the last page (default: 1)
      :class => "pagination" # CSS class name for the generated DIV (default: "pagination")
    )
  end
  
  def float_list(collections, template, obj_name, locals, per_row)
    html = ""
    collections.each_index do |i|
      obj = collections[i]
      html += render(:partial => template, :locals => locals.merge(obj_name => obj))
      html += %Q{<div class="clear_l"></div>} if (i + 1) % per_row == 0
    end
    html
  end
  
  def sanitize_tinymce(html)
    sanitize(html, :attributes => %w(style src href border title))
  end
  
  def community_page_title(page_title)
    content_for(:page_title) { page_title }
  end

  def extract_text(text)
    Hpricot(text || "").inner_text || ""
  end

  def get_riddle_client()
    ThinkingSphinx::Search.get_client(:match_mode => CommunityController::Search_Match_Mode)
  end
  
  def build_excerpts(riddle_client, docs, words, index)
    riddle_client.excerpts(
  		:docs => docs,
  		:words => words,
  		:index => index,
  		:before_match => %Q{<span class="search_match">},
  		:after_match => "</span>",
  		#:chunk_separator => ’ &8230; ’,
  		:limit => 260,
  		:around => 5,
  		:exact_phrase => false,
  		:single_passage => false
  	)
  end
  
end
