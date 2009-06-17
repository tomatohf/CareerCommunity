class AddTalksOrderWeight < ActiveRecord::Migration
  def self.up

    add_column :talk_question_categories, :order_weight, :integer, :limit => 15

    remove_index :talk_question_categories, :talk_id
    add_index :talk_question_categories, [:talk_id, :order_weight]
    
    
    add_column :talk_questions, :order_weight, :integer, :limit => 15
    
    remove_index :talk_questions, :talk_id
    add_index :talk_questions, [:talk_id, :order_weight]
    
    
    add_column :talk_answers, :order_weight, :integer, :limit => 15
    
    remove_index :talk_answers, :question_id
    add_index :talk_answers, [:question_id, :order_weight]
    
    
    
    # set the order_weight field for existing records
    Talk.find(:all).each do |talk|
      
      # for question categories
      question_category_order_weight = 10
      TalkQuestionCategory.find(
        :all,
        :conditions => ["talk_id = ?", talk.id]
      ).each do |question_category|
        question_category.order_weight = question_category_order_weight
        question_category.save!
        
        question_category_order_weight += 10
      end
      
      # for questions
      question_order_weight = 10
      TalkQuestion.find(
        :all,
        :conditions => ["talk_id = ?", talk.id]
      ).each do |question|
        question.order_weight = question_order_weight
        question.save!
        
        question_order_weight += 10
        
        # for question answers
        question_answer_order_weight = 10
        TalkAnswer.find(
          :all,
          :conditions => ["question_id = ?", question.id]
        ).each do |question_answer|
          question_answer.order_weight = question_answer_order_weight
          question_answer.save!

          question_answer_order_weight += 10
        end
      end
      
    end
    
  end

  def self.down
    
    remove_index :talk_answers, [:question_id, :order_weight]
    add_index :talk_answers, :question_id
    
    remove_column :talk_answers, :order_weight
    
    
    remove_index :talk_questions, [:talk_id, :order_weight]
    add_index :talk_questions, :talk_id
    
    remove_column :talk_questions, :order_weight
    
    
    remove_index :talk_question_categories, [:talk_id, :order_weight]
    add_index :talk_question_categories, :talk_id
    
    remove_column :talk_question_categories, :order_weight
    
  end
end
