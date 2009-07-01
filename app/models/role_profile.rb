class RoleProfile < ActiveRecord::Base
  
  include CareerCommunity::AccountBelongings
  
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id, :role_type
  
  validates_length_of :desc, :maximum => 1000, :message => "简介 超过长度限制", :allow_nil => true
  
  
  
  CKP_account_roles = :account_profile_roles
  
  after_save { |role_profile|
    self.clear_account_roles_cache(role_profile.account_id)
  }
  
  after_destroy { |role_profile|
    self.clear_account_roles_cache(role_profile.account_id)
  }
  
  
  def self.get_account_roles(account_id)
    roles = Cache.get("#{CKP_account_roles}_#{account_id}".to_sym)
    
    unless roles
      roles = self.find(
        :all,
        :conditions => ["account_id = ?", account_id]
      ).collect { |role_profile|
        [role_profile.id, role_profile.role_type, role_profile.desc, role_profile.updated_at]
      }
      
      self.set_account_roles_cache(account_id, roles)
    end
    roles
  end
  
  def self.set_account_roles_cache(account_id, roles)
    Cache.set("#{CKP_account_roles}_#{account_id}".to_sym, roles, Cache_TTL)
  end
  
  def self.clear_account_roles_cache(account_id)
    Cache.delete("#{CKP_account_roles}_#{account_id}".to_sym)
  end
  
  
  
  Role_Types = [
    "customer",         # 1
    "industry_expert",  # 2
    "trainer",          # 3
    "kind_hearted"      # 4
  ]
  
  
  def self.ids
    RoleTypes::ID.instance
  end
  
  def self.get_role_type(type_id)
    Role_Types[type_id-1]
  end
  
  def self.get_role_type_handler(type_or_id)
    type = type_or_id.kind_of?(Integer) ? get_role_type(type_or_id) : type_or_id
    eval("RoleTypes::#{type.camelize}").instance
  end
  
  
  module RoleTypes
    
    class ID
      include Singleton
      
      Role_Types.each do |t|
        define_method("#{t}_role_id") {
          i = Role_Types.index(t)
          i && (i+1)
        }
      end
    end
    
    class Base
      include Singleton # use .instance() to return the single instance object
      
      def icon
        ""
      end
      
      def name
        ""
      end
    end
    
    class Customer < Base
      def icon
        "/images/spaces/vip_icon.gif"
      end
      
      def name
        "客户"
      end
    end
    
    class IndustryExpert < Base
      def icon
        "/images/spaces/expert_icon.png"
      end
      
      def name
        "行业专家"
      end
    end
    
    class Trainer < Base
      def icon
        "/images/spaces/expert_icon.png"
      end
      
      def name
        "指导老师"
      end
    end
    
    class KindHearted < Base
      def icon
        "/images/spaces/kind_hearted_icon.gif"
      end
      
      def name
        "互助承诺"
      end
    end
    
  end
  
end
