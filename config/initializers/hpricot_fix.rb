module Hpricot
  
  # fix the question mark issue
  def self.uxs(str)
    str.to_s.
      gsub(/&(\w+);/) { [Hpricot::NamedCharacters[$1] || ??].pack("U*") }.
      gsub(/\&\#(\d+);/) { [$1.to_i].pack("U*") }
  end

  
end