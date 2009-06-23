class CareerTestResult < ActiveRecord::Base
  

  belongs_to :account, :class_name => "Account", :foreign_key => "account_id"

  # ---

  validates_presence_of :account_id, :career_test_id, :answer
  
  
  
  CKP_count = :career_test_result_count
  Count_Cache_Group_Field = :career_test_id
  include CareerCommunity::CountCacheable
  
  
  
  def get_answer
    ((self.answer && self.answer != "") && eval(self.answer)) || {}
  end
  
  def fill_answer(hash_answer)
    self.answer = hash_answer.inspect
  end
  
  def update_answer(hash_answer)
    new_answer = self.get_answer.merge(hash_answer)
    self.fill_answer(new_answer)
  end

end
