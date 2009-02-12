class CreateTalks < ActiveRecord::Migration
  def self.up
    
    # industries table
    create_table :industries, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer, :default => 0
      # set account_id to 0, meaning it is added by system
      
      t.column :name, :string
      
      t.column :desc, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :industries, :created_at
    add_index :industries, :account_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO industries (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM industries WHERE id = 1000")
    
    # talks table
    create_table :talks, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :creator_id, :integer
      t.column :updater_id, :integer
      
      t.column :title, :string
      t.column :info, :text
      # info column includes:
      #   desc
      #   summary
      
      t.column :sn, :string
      t.column :place, :string
      
      t.column :begin_at, :datetime
      t.column :end_at, :datetime
      
      t.column :published, :boolean, :default => false
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :talks, :created_at
    add_index :talks, :creator_id
    add_index :talks, :updater_id
    add_index :talks, :sn
    add_index :talks, :begin_at
    add_index :talks, :end_at
    add_index :talks, :published
    add_index :talks, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO talks (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM talks WHERE id = 1000")
    
    # talk_reporters table
    create_table :talk_reporters, :force => true do |t|
      t.column :talk_id, :integer
      t.column :created_at, :datetime
      
      t.column :name, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :talk_reporters, :talk_id
    add_index :talk_reporters, :created_at
    add_index :talk_reporters, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO talk_reporters (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM talk_reporters WHERE id = 1000")
    
    # talk_talkers table
    create_table :talk_talkers, :force => true do |t|
      t.column :talk_id, :integer
      t.column :created_at, :datetime
      
      t.column :talker_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :talk_talkers, :talk_id
    add_index :talk_talkers, :created_at
    add_index :talk_talkers, :talker_id
    add_index :talk_talkers, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO talk_talkers (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM talk_talkers WHERE id = 1000")
    
    # talk_question_categories table
    create_table :talk_question_categories, :force => true do |t|
      t.column :talk_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :creator_id, :integer
      t.column :updater_id, :integer
      
      t.column :name, :string
      
      t.column :desc, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :talk_question_categories, :created_at
    add_index :talk_question_categories, :talk_id
    add_index :talk_question_categories, :creator_id
    add_index :talk_question_categories, :updater_id
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO talk_question_categories (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM talk_question_categories WHERE id = 1000")
    
    # talk_questions table
    create_table :talk_questions, :force => true do |t|
      t.column :talk_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :creator_id, :integer
      t.column :updater_id, :integer
      
      t.column :question, :string
      
      t.column :summary, :string
      
      t.column :category_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :talk_questions, :talk_id
    add_index :talk_questions, :created_at
    add_index :talk_questions, :creator_id
    add_index :talk_questions, :updater_id
    add_index :talk_questions, :category_id
    add_index :talk_questions, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO talk_questions (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM talk_questions WHERE id = 1000")
    
    # talk_answers table
    create_table :talk_answers, :force => true do |t|
      t.column :talk_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :creator_id, :integer
      t.column :updater_id, :integer
      
      t.column :question_id, :integer
      t.column :talker_id, :integer
      
      t.column :answer, :text
      
      t.column :summary, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :talk_answers, :talk_id
    add_index :talk_answers, :created_at
    add_index :talk_answers, :creator_id
    add_index :talk_answers, :updater_id
    add_index :talk_answers, :question_id
    add_index :talk_answers, :talker_id
    add_index :talk_answers, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO talk_answers (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM talk_answers WHERE id = 1000")
    
    # talkers table
    create_table :talkers, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :real_name, :string, :limit => 50
      t.column :gender, :boolean
      t.column :age, :string
      t.column :nick, :string
      
      t.column :company, :string
      t.column :position, :string
      
      t.column :email, :string
      t.column :mobile, :string, :limit => 25
      t.column :phone, :string, :limit => 25
      
      t.column :msn, :string
      t.column :gtalk, :string
      t.column :qq, :string, :limit => 20
      t.column :skype, :string
      
      t.column :experience, :string, :limit => 1000
      
      t.column :other, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :talkers, :real_name
    add_index :talkers, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO talkers (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM talkers WHERE id = 1000")
    
    # talk_comments table
    create_table :talk_comments, :force => true do |t|
      t.column :talk_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :talk_comments, :talk_id
    add_index :talk_comments, :account_id
    add_index :talk_comments, :created_at
    add_index :talk_comments, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO talk_comments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM talk_comments WHERE id = 1000")
    
    
    # talk_question_tags
    create_table :talk_question_tags, :force => true do |t|
      t.column :name, :string
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :talk_question_tags, :name
    add_index :talk_question_tags, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO talk_question_tags (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM talk_question_tags WHERE id = 1000")

    # talk_questions_talk_question_tags table
    # create the talk_question relationship table
    create_table :talk_questions_talk_question_tags, :id => false, :force => true do |t|
      t.column :talk_question_id, :integer
      t.column :talk_question_tag_id, :integer
    end
    add_index :talk_questions_talk_question_tags, :talk_question_id
    add_index :talk_questions_talk_question_tags, :talk_question_tag_id
    
    
    # talks_companies table
    create_table :talks_companies, :id => false, :force => true do |t|
      t.column :talk_id, :integer
      t.column :company_id, :integer
    end
    add_index :talks_companies, :talk_id
    add_index :talks_companies, :company_id
    
    # talks_job_positions table
    create_table :talks_job_positions, :id => false, :force => true do |t|
      t.column :talk_id, :integer
      t.column :job_position_id, :integer
    end
    add_index :talks_job_positions, :talk_id
    add_index :talks_job_positions, :job_position_id
    
    # talks_industries table
    create_table :talks_industries, :id => false, :force => true do |t|
      t.column :talk_id, :integer
      t.column :industry_id, :integer
    end
    add_index :talks_industries, :talk_id
    add_index :talks_industries, :industry_id
    
  end

  def self.down
    drop_table :talks_industries
    drop_table :talks_job_positions
    drop_table :talks_companies
    
    drop_table :talk_questions_talk_question_tags
    drop_table :talk_question_tags
    
    drop_table :talk_comments
    drop_table :talkers
    drop_table :talk_answers
    drop_table :talk_questions
    drop_table :talk_question_categories
    drop_table :talk_talkers
    drop_table :talk_reporters
    drop_table :talks
    drop_table :industries
  end
end
