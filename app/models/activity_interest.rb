class ActivityInterest < ActiveRecord::Base
  
  belongs_to :activity, :class_name => "Activity", :foreign_key => "activity_id"
  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :activity_id, :account_id
  
  
  
  def self.is_interest_activity(account_id, activity_id)
    self.find(:first, :conditions => ["activity_id = ? and account_id = ?", activity_id, account_id])
  end
  
  def self.add_interest_activity(account_id, activity_id)
    activity_interest = ActivityInterest.new(:account_id => account_id, :activity_id => activity_id)
    activity_interest.save
  end
  
  def self.paginate_activity_interest_accounts(activity_id, page, page_size)
    self.paginate(
      :page => page,
      :per_page => page_size,
      :conditions => ["activity_id = ?", activity_id],
      :include => [:account => [:profile_pic]],
      :order => "created_at DESC"
    )
  end
  
end