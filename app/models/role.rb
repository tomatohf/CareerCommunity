class Role < ActiveRecord::Base

  has_and_belongs_to_many :accounts, :foreign_key => "role_id"

  # ---

  validates_presence_of :name
  
  
  
  def self.admin_name
    "admin"
  end
  
  def self.admin_role
    self.find(:first, :conditions => ["name = ?", self.admin_name])
  end

end
