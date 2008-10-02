# I18n Module 
# License: http://www.apache.org/licenses/LICENSE-2.0.html 
# URL: http://www.reality.hk/articles/2007/02/20/681/ 
# 
# Modified from Localization module at mir.aculo.us 
# http://mir.aculo.us/2005/10/03/ruby-on-rails-i18n-revisited 
# 
# Thanks Takol for idea to use HTTP_ACCEPT_LANGUAGE to select language
# http://takol.tw/data/326894672446572cc5.html


# Tomato customized it by commenting some rows

 
module I18n 
#  PARAMETER_LANG = 'lang'
  
  #@@l10s = { "default" => {} } 
  #@@lang = "default" 
  
  @@l10s = {} 
  @@lang = ""

#  def lang_filter
#    usr_lang = self.request.parameters[PARAMETER_LANG] ||= request.env['HTTP_ACCEPT_LANGUAGE'].to_s.scan(/\w*\-\w*/).first
#    I18n.lang = I18n.lang?(usr_lang) ? usr_lang : :default 
#  end
#
#  def self.included(base) #:nodoc:
#    base.send(:before_filter, :lang_filter)
#  end
  
  def self._(string_to_localize, *args) 
    translated = get_translated string_to_localize
    return translated.call(*args).to_s if translated.is_a? Proc 
    translated = 
      translated[args[0]>1 ? 1 : 0] if translated.is_a?(Array) 
    sprintf translated, *args 
  end 
  
  # added by Tomato to fix the nil object error
  def self.get_translated string_to_localize
    translated = if I18n.lang? @@lang
      # found in existing
      @@l10s[@@lang][string_to_localize]
    else
      # try to make existing key [en-US] can accept the lang [en]
      keys = @@l10s.keys
      mapped_keys = keys.select { |k| k.downcase.include? @@lang.downcase }
      if mapped_keys.size > 0
        @@lang = mapped_keys[0]
        @@l10s[@@lang][string_to_localize]
      else
        # try to make existing key [en] can accept the lang [en-US]
        splitted_lang = @@lang.split "-", 2
        unless splitted_lang.size < 2
          mapped_keys = keys.select { |k| k.downcase.include? splitted_lang[0].downcase }
          if mapped_keys.size > 0
            @@lang = mapped_keys[0]
            @@l10s[@@lang][string_to_localize]
          end
        end
      end
    end
    
    # output the en language as the default
    translated ||= @@l10s["en"][string_to_localize]
    # if the en language can not be found,
    # output the key with notice
    translated ||= "###" + string_to_localize + "###"
    translated
  end
  
  def self.load 
    loaded = [] 
    Dir.glob("#{RAILS_ROOT}/config/lang/*.yml"){ |yml| 
      name = File.basename(yml, ".yml") 
      translate = YAML.load_file(yml) 
      I18n.define(name, translate) 
      loaded << name 
    }
#    printf("=> mob_i18n: loaded languages: #{loaded.join(', ')}\n")
    return loaded 
  end 
 
  def self.define(lang = "default", dictionary = {}) 
    @@l10s[lang] = dictionary 
  end 
 
  def self.lang?(lang) 
    @@l10s.key?(lang) 
  end
  
  def self.lang
    @@lang
  end
  
  def self.set_lang lang
    @@lang = lang
    # default language is [en]
    @@lang = "en" if @@lang.nil? || @@lang == ""
  end
end 

class Object 
  def _(*args); I18n._(*args); end 
end