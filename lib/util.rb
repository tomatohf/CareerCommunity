module CareerCommunity
  
  module AccountBelongings
    
    def self.included(belongings)
      def belongings.get_by_account(account_id, args = {})
        self.find(:first, args.merge(:conditions => ["account_id = ?", account_id]))
      end
      
      def belongings.get_all_by_account(account_id, args = {})
        self.find(:all, args.merge(:conditions => ["account_id = ?", account_id]))
      end
    end
    
  end

  module Util
    
    private
    
    def self.included(klass)
      def klass.expand_cache_key(key)
        ActiveSupport::Cache.expand_cache_key(key, :views)
      end
    end
    
    def deep_copy(ar)
      Marshal::load(Marshal.dump(ar))
    end
    
    def truncate_text(text, len, append = "...")
      return "" if text.nil?
      text.chars.length > len ? text.chars[0...(len - append.chars.length)] + append : text
    end
    
    def get_unique_id
      now = Time.now
      "#{now.to_i}_#{now.usec}_#{Process.pid}"
    end
    
    #  password length:
    #  level 0 (3 point): less than 4 characters
    #  level 1 (6 points): between 5 and 7 characters
    #  level 2 (12 points): between 8 and 15 characters
    #  level 3 (18 points): 16 or more characters
    #  
    #  letters:
    #  level 0 (0 points): no letters
    #  level 1 (5 points): all letters are lower case
    #  level 2 (7 points): letters are mixed case
    #  
    #  numbers:
    #  level 0 (0 points): no numbers exist
    #  level 1 (5 points): one number exists
    #  level 1 (7 points): 3 or more numbers exists
    #  
    #  special characters:
    #  level 0 (0 points): no special characters
    #  level 1 (5 points): one special character exists
    #  level 2 (10 points): more than one special character exists
    #  
    #  combinatons:
    #  level 0 (1 points): letters and numbers exist
    #  level 1 (1 points): mixed case letters
    #  level 1 (2 points): letters, numbers and special characters 
    #           exist
    #  level 1 (2 points): mixed case letters, numbers and special 
    #           characters exist
    def check_password_strength(pwd)
      score = 0
      log = []
  
      # PASSWORD LENGTH
      if pwd.size > 0 && pwd.size < 5
        # length 4 or less
        score += 3
        log << "3 points for length (#{pwd.size})"
      elsif pwd.size > 4 && pwd.size < 8
        # length between 5 and 7
        score += 6
        log << "6 points for length (#{pwd.size})"
      elsif pwd.size > 7 && pwd.size < 16
        # length between 8 and 15
        score += 12
        log << "12 points for length (#{pwd.size})"
      elsif pwd.size > 15
        # length 16 or more
        score += 18
        log << "18 point for length (#{pwd.size})"
      end
  
      # LETTERS (Not exactly implemented as dictacted above because of my limited understanding of Regex)
      if pwd =~ /[a-z]/
        # [verified] at least one lower case letter
        score += 1
        log << "1 point for at least one lower case char"
      end
  
      if pwd =~ /[A-Z]/
        # [verified] at least one upper case letter
        score += 5
        log << "5 points for at least one upper case char"
      end
  
      # NUMBERS
      if pwd =~ /\d+/
        # [verified] at least one number
        score += 5
        log << "5 points for at least one number"
      end
  
      numbers = pwd.scan(/\d/)
      if numbers.size >= 3
        # [verified] at least three numbers
        score += 5
        log << "5 points for at least three numbers"
      end
  
      # SPECIAL CHAR
      if pwd =~ /[^a-zA-Z0-9]/
        # [verified] at least one special character
        score += 5
        log << "5 points for at least one special char"
      end
  
      # [verified] at least two special characters
      symbols = pwd.scan(/[^a-zA-Z0-9]/)
      if symbols.size >= 2
        score += 5
        log << "5 points for at least two special chars"
      end
  
      # COMBOS
      if pwd =~ /([a-z].*[A-Z])|([A-Z].*[a-z])/
        # [verified] both upper and lower case
        score += 2
        log << "2 combo points for upper and lower letters"
      end
  
      if pwd =~ /([a-zA-Z])/ && pwd =~ /([0-9])/
        # [verified] both letters and numbers
        score += 2
        log << "2 combo points for letters and numbers"
      end
  
      # [verified] letters, numbers, and special characters
      if pwd =~ /([a-zA-Z0-9].*[^a-zA-Z0-9])|([^a-zA-Z0-9].*[a-zA-Z0-9])/
        score += 2
        log << "2 combo points for letters, numbers and special chars"
      end
      
      [score, log]
    end
    
  end

end
