class ActivityMember < ActiveRecord::Base
  
  belongs_to :activity, :class_name => "Activity", :foreign_key => "activity_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :activity_id, :account_id
  
  
  
  before_save { |activity_member|
    if activity_member.join_at_was.nil? && activity_member.join_at.kind_of?(DateTime)
      AccountAction.create_new(activity_member.account_id, "join_activity", {
        :activity_id => activity_member.activity_id
      })
    end
  }
  
  
  named_scope :agreed, :conditions => { :accepted => true, :approved => true }
  
  
  
  def agreed
    self.accepted && self.approved
  end
  
  def self.is_activity_member(activity_id, account_id)
    self.agreed.find(:first, :conditions => ["activity_id = ? and account_id = ?", activity_id, account_id])
  end
  
  def self.is_activity_admin(activity_id, account_id)
    self.agreed.find(:first, :conditions => ["activity_id = ? and account_id = ? and admin = ?", activity_id, account_id, true])
  end
  
  def self.get_by_activity_and_account(activity_id, account_id)
    self.find(:first, :conditions => ["activity_id = ? and account_id = ?", activity_id, account_id])
  end
  
  def self.add_account_to_activity(activity_id, account_id, as_admin = false)
    activity_member = self.get_by_activity_and_account(activity_id, account_id) || 
                    self.new(:activity_id => activity_id, :account_id => account_id)
    
    activity_member.accepted = true
    activity_member.approved = true
    activity_member.join_at ||= DateTime.now
    activity_member.admin ||= as_admin
    activity_member.save
  end
  
  def self.remove_account_from_activity(activity_id, account_id)
    self.delete_all(["activity_id = ? and account_id = ?", activity_id, account_id])
  end
  
  def self.join_activity(activity_id, account_id, need_approve = false)
    activity_member = self.get_by_activity_and_account(activity_id, account_id) || 
                    self.new(:activity_id => activity_id, :account_id => account_id)
                    
    activity_member.accepted = true
    activity_member.approved ||= (!need_approve)
    activity_member.join_at ||= DateTime.now if activity_member.agreed
    activity_member.save
    activity_member
  end
  
  def self.paginate_activity_members(activity_id, page, page_size)
    self.agreed.paginate(
      :page => page,
      :per_page => page_size,
      :conditions => ["activity_id = ?", activity_id],
      :include => [:account => [:profile_pic]],
      :order => "join_at DESC"
    )
  end
  
  def self.approve_all(activity_id)
    self.update_all(["approved = ?, join_at = ?", true, DateTime.now], ["activity_id = ? and approved = ? and accepted = ?", activity_id, false, true])
  end
  
  def self.paginate_unapproved_members(activity_id, page, page_size)
    self.paginate(
      :page => page,
      :per_page => page_size,
      :conditions => ["activity_id = ? and accepted = ? and approved = ?", activity_id, true, false],
      :include => [:account => [:profile_pic]],
      :order => "created_at ASC"
    )
  end
  
  def self.get_unaccepted_members(activity_id)
    self.find(
      :all,
      :conditions => ["activity_id = ? and accepted = ? and approved = ?", activity_id, false, true],
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
  end
  
  def self.paginate_activity_attend_members(activity_id, page, page_size)
    self.agreed.paginate(
      :page => page,
      :per_page => page_size,
      :conditions => ["activity_id = ? && absent = ?", activity_id, false],
      :include => [:account => [:profile_pic]],
      :order => "join_at DESC"
    )
  end
  
  def self.get_activity_absent_members(activity_id)
    self.agreed.find(
      :all,
      :conditions => ["activity_id = ? && absent = ?", activity_id, true],
      :include => [:account => [:profile_pic]],
      :order => "join_at DESC"
    )
  end
  
  def self.count_activity_member(activity_id)
    self.agreed.count(:conditions => ["activity_id = ?", activity_id])
  end
  
end