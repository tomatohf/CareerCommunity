class GroupMember < ActiveRecord::Base
  
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :group_id, :account_id
  
  
  
  after_save { |group_member|
    if group_member.join_at_was.nil? && group_member.join_at.kind_of?(DateTime)
      AccountAction.create_new(group_member.account_id, "join_group", {
        :group_id => group_member.group_id
      })
    end
    
    self.clear_account_group_ids_cache(group_member.account_id)
    
    self.clear_account_admin_group_ids_cache(group_member.account_id)
  }
  
  after_destroy { |group_member|
    self.clear_account_group_ids_cache(group_member.account_id)
    
    self.clear_account_admin_group_ids_cache(group_member.account_id) if group_member.admin
  }
  
  
  
  CKP_account_group_ids = :account_group_ids
  CKP_account_admin_group_ids = :account_admin_group_ids
  
  
  named_scope :agreed, :conditions => { :accepted => true, :approved => true }
  
  
  
  def self.get_account_group_ids(account_id)
    a_g_id = Cache.get("#{CKP_account_group_ids}_#{account_id}".to_sym)
    
    unless a_g_id
      members = self.agreed.find(
    	  :all,
    		:conditions => ["account_id = ?", account_id]
    	)
      
      a_g_id = self.set_account_group_ids(account_id, members)
    end
    a_g_id
  end
  
  def self.set_account_group_ids(account_id, members)
    a_g_id = members.collect { |m| m.group_id }
    
    self.set_account_group_ids_cache(account_id, a_g_id)
    
    a_g_id
  end
  
  def self.set_account_group_ids_cache(account_id, a_g_id)
    Cache.set("#{CKP_account_group_ids}_#{account_id}".to_sym, a_g_id, Cache_TTL)
  end
  
  def self.clear_account_group_ids_cache(account_id)
    Cache.delete("#{CKP_account_group_ids}_#{account_id}".to_sym)
  end
  
  
  def self.get_account_admin_group_ids(account_id)
    a_g_id = Cache.get("#{CKP_account_admin_group_ids}_#{account_id}".to_sym)
    
    unless a_g_id
      admin_members = self.agreed.find(
    	  :all,
    		:conditions => ["account_id = ? and admin = ?", account_id, true]
    	)
      
      a_g_id = self.set_account_admin_group_ids(account_id, admin_members)
    end
    a_g_id
  end
  
  def self.set_account_admin_group_ids(account_id, admin_members)
    a_g_id = admin_members.collect { |m| m.group_id }
    
    Cache.set("#{CKP_account_admin_group_ids}_#{account_id}".to_sym, a_g_id, Cache_TTL)
    
    a_g_id
  end
  
  def self.clear_account_admin_group_ids_cache(account_id)
    Cache.delete("#{CKP_account_admin_group_ids}_#{account_id}".to_sym)
  end
  
  
  
  def agreed
    self.accepted && self.approved
  end
  
  def self.get_group_member(group_id, account_id)
    self.agreed.find(:first, :conditions => ["group_id = ? and account_id = ?", group_id, account_id])
  end
  
  def self.is_group_member(group_id, account_id)
    group_ids = self.get_account_group_ids(account_id)
    group_ids.include?(group_id.to_i)
  end
  
  def self.get_group_admin(group_id, account_id)
    self.agreed.find(:first, :conditions => ["group_id = ? and account_id = ? and admin = ?", group_id, account_id, true])
  end
  
  def self.is_group_admin(group_id, account_id)
    group_ids = self.get_account_admin_group_ids(account_id)
    group_ids.include?(group_id.to_i)
  end
  
  def self.get_by_group_and_account(group_id, account_id)
    self.find(:first, :conditions => ["group_id = ? and account_id = ?", group_id, account_id])
  end
  
  def self.add_account_to_group(group_id, account_id, as_admin = false)
    group_member = self.get_by_group_and_account(group_id, account_id) || 
                    self.new(:group_id => group_id, :account_id => account_id)
    
    group_member.accepted = true
    group_member.approved = true
    group_member.join_at ||= DateTime.now
    group_member.admin ||= as_admin
    group_member.save
  end
  
  def self.remove_account_from_group(group_id, account_id)
    self.find(
      :all,
      :conditions => ["group_id = ? and account_id = ?", group_id, account_id]
    ).each { |gm| gm.destroy }
  end
  
  def self.join_group(group_id, account_id, need_approve = false)
    group_member = self.get_by_group_and_account(group_id, account_id) || 
                    self.new(:group_id => group_id, :account_id => account_id)
                    
    group_member.accepted = true
    group_member.approved ||= (!need_approve)
    group_member.join_at ||= DateTime.now if group_member.agreed
    group_member.save
    group_member
  end
  
  def self.get_group_admins(group_id, include_account = true)
    options = {
      :conditions => ["group_id = ? and admin = ?", group_id, true],
      :order => "join_at ASC"
    }
    options[:include] = [:account => [:profile_pic]] if include_account
    
    self.agreed.find(:all, options)
  end
  
  def self.count_admin(group_id)
    self.agreed.count(:conditions => ["group_id = ? and admin = ?", group_id, true])
  end
  
  def self.paginate_group_members(group_id, page, page_size)
    self.agreed.paginate(
      :page => page,
      :per_page => page_size,
      :conditions => ["group_id = ? and admin = ?", group_id, false],
      :include => [:account => [:profile_pic]],
      :order => "join_at ASC"
    )
  end
  
  def self.approve_all(group_id)
    self.update_all(["approved = ?, join_at = ?", true, DateTime.now], ["group_id = ? and approved = ? and accepted = ?", group_id, false, true])
  end
  
  def self.paginate_unapproved_members(group_id, page, page_size)
    self.paginate(
      :page => page,
      :per_page => page_size,
      :conditions => ["group_id = ? and accepted = ? and approved = ?", group_id, true, false],
      :include => [:account => [:profile_pic]]
    )
  end
  
  def self.get_unaccepted_members(group_id)
    self.find(
      :all,
      :conditions => ["group_id = ? and accepted = ? and approved = ?", group_id, false, true],
      :include => [:account => [:profile_pic]]
    )
  end
  
  
  def self.load_group_with_image(members)
    preload_associations(members, [:group => [:image]])
  end
  
end