class ImproveTalksIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :talks, :created_at
    remove_index :talks, :creator_id
    remove_index :talks, :updater_id
    remove_index :talks, :sn
    remove_index :talks, :begin_at
    remove_index :talks, :end_at
    remove_index :talks, :published
    remove_index :talks, :publish_at
    
    add_index :talks, [:published, :publish_at]
    
    
    # remove_index :talk_reporters, :talk_id
    remove_index :talk_reporters, :created_at
    
    
    # remove_index :talk_talkers, :talk_id
    remove_index :talk_talkers, :created_at
    # remove_index :talk_talkers, :talker_id
    
    
    remove_index :talk_question_categories, :created_at
    # remove_index :talk_question_categories, :talk_id
    remove_index :talk_question_categories, :creator_id
    remove_index :talk_question_categories, :updater_id
    
    
    # remove_index :talk_questions, :talk_id
    remove_index :talk_questions, :created_at
    remove_index :talk_questions, :creator_id
    remove_index :talk_questions, :updater_id
    remove_index :talk_questions, :category_id
    
    
    remove_index :talk_answers, :talk_id
    remove_index :talk_answers, :created_at
    remove_index :talk_answers, :creator_id
    remove_index :talk_answers, :updater_id
    # remove_index :talk_answers, :question_id
    remove_index :talk_answers, :talker_id
    
    
    remove_index :talkers, :real_name
    
    
    remove_index :talk_comments, :talk_id
    remove_index :talk_comments, :account_id
    remove_index :talk_comments, :created_at
    
    add_index :talk_comments, [:talk_id, :created_at]
    
    
    # remove_index :job_tags, :name
    
    
    remove_index :talk_questions_job_tags, :talk_question_id
    remove_index :talk_questions_job_tags, :job_tag_id
    
    add_index :talk_questions_job_tags, [:talk_question_id, :job_tag_id], :unique => true
    
    
    remove_index :talks_companies, :talk_id
    remove_index :talks_companies, :company_id
    
    add_index :talks_companies, [:talk_id, :company_id], :unique => true
    
    
    remove_index :talks_job_positions, :talk_id
    remove_index :talks_job_positions, :job_position_id
    
    add_index :talks_job_positions, [:talk_id, :job_position_id], :unique => true
    
    
    remove_index :talks_industries, :talk_id
    remove_index :talks_industries, :industry_id
    
    add_index :talks_industries, [:talk_id, :industry_id], :unique => true
    
    
    remove_index :talks_job_processes, :talk_id
    remove_index :talks_job_processes, :job_process_id
    
    add_index :talks_job_processes, [:talk_id, :job_process_id], :unique => true
    
  end

  def self.down
    
    remove_index :talks_job_processes, [:talk_id, :job_process_id]
    
    add_index :talks_job_processes, :talk_id
    add_index :talks_job_processes, :job_process_id
    
    
    remove_index :talks_industries, [:talk_id, :industry_id]
    
    add_index :talks_industries, :talk_id
    add_index :talks_industries, :industry_id
    
    
    remove_index :talks_job_positions, [:talk_id, :job_position_id]
    
    add_index :talks_job_positions, :talk_id
    add_index :talks_job_positions, :job_position_id
    
    
    remove_index :talks_companies, [:talk_id, :company_id]
    
    add_index :talks_companies, :talk_id
    add_index :talks_companies, :company_id
    
    
    remove_index :talk_questions_job_tags, [:talk_question_id, :job_tag_id]
    
    add_index :talk_questions_job_tags, :talk_question_id
    add_index :talk_questions_job_tags, :job_tag_id
    
    
    # add_index :job_tags, :name
    
    
    remove_index :talk_comments, [:talk_id, :created_at]
    
    add_index :talk_comments, :talk_id
    add_index :talk_comments, :account_id
    add_index :talk_comments, :created_at
    
    
    add_index :talkers, :real_name
    
    
    add_index :talk_answers, :talk_id
    add_index :talk_answers, :created_at
    add_index :talk_answers, :creator_id
    add_index :talk_answers, :updater_id
    # add_index :talk_answers, :question_id
    add_index :talk_answers, :talker_id
    
    
    # add_index :talk_questions, :talk_id
    add_index :talk_questions, :created_at
    add_index :talk_questions, :creator_id
    add_index :talk_questions, :updater_id
    add_index :talk_questions, :category_id
    
    
    add_index :talk_question_categories, :created_at
    # add_index :talk_question_categories, :talk_id
    add_index :talk_question_categories, :creator_id
    add_index :talk_question_categories, :updater_id
    
    
    # add_index :talk_talkers, :talk_id
    add_index :talk_talkers, :created_at
    # add_index :talk_talkers, :talker_id
    
    
    # add_index :talk_reporters, :talk_id
    add_index :talk_reporters, :created_at
    
    
    remove_index :talks, [:published, :publish_at]
    
    add_index :talks, :created_at
    add_index :talks, :creator_id
    add_index :talks, :updater_id
    add_index :talks, :sn
    add_index :talks, :begin_at
    add_index :talks, :end_at
    add_index :talks, :published
    add_index :talks, :publish_at
    
  end
end

