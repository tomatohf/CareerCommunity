# default value
# XmlMini.backend = 'REXML'



# To use the much faster libxml parser:
# gem 'libxml-ruby', '=0.9.7'
# XmlMini.backend = 'LibXML'

ActiveSupport::XmlMini.backend = "LibXML"

