class CorrectTalksOrderWeightLimit < ActiveRecord::Migration
  def self.up

    change_column :talk_question_categories, :order_weight, :integer, :limit => 2
    
    change_column :talk_questions, :order_weight, :integer, :limit => 2
    
    change_column :talk_answers, :order_weight, :integer, :limit => 2
    
  end

  def self.down
    
    # do nothing, since is's CORRECTION, not CHANGE
    # no need to rollback
    
  end
end
