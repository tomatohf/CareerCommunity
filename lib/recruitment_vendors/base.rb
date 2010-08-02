module RecruitmentVendor
  
  @@vendors = {
    # "file_name_without_rb" => "class name"
    
    #"sjtubbs" => "Sjtubbs",
    #"utomorrow" => "Utomorrow",
    "yjs54" => "Yjs54",
    "hiall" => "Hiall",
    # "guolairen" => "Guolairen",
    # "yingjiesheng" => "Yingjiesheng",
    "maiwo" => "Maiwo"
  }
  
  
  def self.vendor_classess
    @@vendors.values.collect { |value| "RecruitmentVendor::#{value}" }
  end
  
  module Base
    
    def source_name
      self.class.to_s
    end
    
    def get_doc_from_url!(url, handle, document_encoding = "GBK")
      ic = Iconv.new("UTF-8//IGNORE", "#{document_encoding}//IGNORE")
      page = open(
        url,        
        "User-Agent" => "Mozilla"
      )
      page_content = ic.iconv(page.read)
      doc = Hpricot(page_content)
      
      if handle
        
        # remove troublesome elemtns
        troublesome_elements.each {|element| doc.search("//#{element}").remove }
        
      end
      
      doc
    end

    def get_doc_from_url(url, handle, document_encoding = "GBK")
      begin
        doc = get_doc_from_url!(url, handle, document_encoding)
      rescue
        doc = nil
      end
    
      doc
    end
    
    def troublesome_elements
      [
        "img",
        "script",
        "iframe",
        "embed",
        "object"
      ]
    end
    
    def troublesome_attributes_in_content
      [
        "class",
        "width"
      ]
    end
    
    def after_filter_replace_match_rules
      [
        # sample ...
        #{
          # :all => ["target1", "replaced", /regexp/]
          # :content => ["target1", "replaced", /regexp/]
        #},
        # sample ...
        #{
          # :all => [Proc.new{|match, match_data| "<#{match}>" }, "replaced", /regexp/]
          # :content => [Proc.new{|match, match_data| "<#{match}>" }, "replaced", /regexp/]
        #}
      ]
    end
    
    def before_filter_replace_match_rules
      [
        {
          :content => [
            Proc.new { |match, match_data|
              href = match_data[1]
              text = match_data[2]
              if href != text
                # should disable the link
                text
              else
                # do not change
                match_data[0]
              end
            }, 
            /<a.*?href="(.*?)".*?>(.*?)<\/a>/im
          ]
        }
      ]
    end
    
    def filter_match_rules
      [
        # sample ...
        #{
          # :all => [/regexp1/, /regexp2/]
          # :content => [/regexp1/, /regexp2/]
        #}
        
        :all => Recruitment::Filter_Out_Key_Words
      ]
    end
    
    def all_fields
      [:title, :content, :location]
    end
    
    
    # method get_new_links should return a hash containing all *new* links, from which we should fetch information
    # method get_info_obj method return a Recruitment model object by the information got from the link
    def collect_new_messages(start_page = 1, page_count = 1)
      gotten_new_links = get_new_links(start_page, page_count)
      
      non_existing_links = remove_existing_links(gotten_new_links)
      
      non_existing_links.to_a.collect { |link_info| get_info_obj(link_info[0], link_info[1]) }.compact
    end
    
    def remove_existing_links(links)
      existing_links = Recruitment.find(
        :all, 
        :select => "source_link", 
        :conditions => ["source_link in (?)", links.keys]
      ).collect { |r| r.source_link }
      links.delete_if { |key, value| existing_links.include?(key) }
    end
    
    def save_new_messages(start_page = 1, page_count = 1)
      self.collect_new_messages(start_page, page_count).values.flatten.each { |message| message.save }
    end
    
    def get_info_obj(link, init_values = {})
      info_obj = build_info_obj(link, init_values)
      
      return nil if info_obj.nil?
      
      # set the flag to indicate that this message is collected automatically
      info_obj.account_id = -1
      
      # remove the troublesome attribute values in content such as class
      troublesome_attributes_in_content.each { |attr| Hpricot(info_obj.content).search("[@#{attr}]").each{|element| element.remove_attribute(attr) } }
      
      # apply replace_match_rules
      apply_replace_match_rules(info_obj, before_filter_replace_match_rules)
      
      # apply filter_match_rules
      return nil if filter_match_rules_applicable?(info_obj)

      # apply replace_match_rules
      apply_replace_match_rules(info_obj, after_filter_replace_match_rules)
      
      # return the info_obj model object
      info_obj
    end
    
    def filter_match_rules_applicable?(info_obj)
      filter_match_rules.each do |rule|
        rule.each_pair do |key, value|
          fields = key == :all ? all_fields : [key]
          
          fields.each do |field|
            value.each do |pattern|
              return true if info_obj.send(field) =~ pattern
            end
          end
        end
      end
      
      false
    end
    
    def apply_replace_match_rules(info_obj, rules)
      rules.each do |rule|
        rule.each_pair do |key, value|
          fields = key == :all ? all_fields : [key]
          
          target = value.shift
          fields.each do |field|
            value.each do |pattern|
              field_value = info_obj.send(field)

              unless field_value.nil?
                field_value.gsub!(pattern) {|match| target.kind_of?(Proc) ? target.call(match, $~) : target }
              
                info_obj.send("#{field}=", field_value)
              end
            end
          end
        end
      end
    end
    
  end
  
  
  @@vendors.keys.each { |file| require_dependency "recruitment_vendors/#{file}" }
  
end


class Array
    
  # block should return two values, the 1st value is the hash key and the 2nd value is the hash value
  def build_hash(&block)
    Hash[*self.collect{|item| block.call(item) }.flatten]
  end
  
  def build_hash_keys(&block)
    Hash[*self.collect { |v|
      [v, block.call(v)]
    }.flatten]
  end
  
  def build_hash_values(&block)
    Hash[*self.collect { |v|
      [block.call(v), v]
    }.flatten]
  end
  
end