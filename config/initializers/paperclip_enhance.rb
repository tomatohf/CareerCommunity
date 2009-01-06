# enable the ability to access photo.album_id in path&url pattern



module Paperclip
  class Attachment
    
    #alias original_initialize initialize
    def self.interpolations
      @interpolations ||= {
        :rails_root   => lambda{|attachment,style| RAILS_ROOT },
        :class        => lambda do |attachment,style|
                           attachment.instance.class.name.underscore.pluralize
                         end,
        :basename     => lambda do |attachment,style|
                           attachment.original_filename.gsub(File.extname(attachment.original_filename), "")
                         end,
#        :extension    => lambda do |attachment,style| 
#                           ((style = attachment.styles[style]) && style.last) ||
#                           File.extname(attachment.original_filename).gsub(/^\.+/, "")
#                         end,

        # changed by Tomato, to modify the ext name to lowercase
        :extension    => lambda do |attachment,style| 
                           ext_name = ((style = attachment.styles[style]) && style.last) ||
                           File.extname(attachment.original_filename).gsub(/^\.+/, "")
                           ext_name.downcase
                         end,

        :id           => lambda{|attachment,style| attachment.instance.id },
        
        # added by Tomato
        # :album_id     => lambda{|attachment,style| attachment.instance.respond_to?("album_id", false) ? attachment.instance.album_id : "" },
        :created_year => lambda{|attachment,style| attachment.instance.created_at.year },
        :created_month => lambda{|attachment,style| attachment.instance.created_at.month },
        :created_mday => lambda{|attachment,style| attachment.instance.created_at.mday },
        
        :id_partition => lambda do |attachment, style|
                           ("%09d" % attachment.instance.id).scan(/\d{3}/).join("/")
                         end,
        :attachment   => lambda{|attachment,style| attachment.name.to_s.downcase.pluralize },
        :style        => lambda{|attachment,style| style || attachment.default_style },
      }
    end
    
  end
end


