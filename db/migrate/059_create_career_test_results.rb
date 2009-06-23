class CreateCareerTestResults < ActiveRecord::Migration
  def self.up
    
    # career_test_results table
    create_table :career_test_results, :force => true do |t|
      t.column :created_at, :datetime
      
      t.column :account_id, :integer
      t.column :career_test_id, :integer
      
      t.column :answer, :text
    end
    add_index :career_test_results, [:account_id, :created_at]
    add_index :career_test_results, [:career_test_id, :created_at]
    add_index :career_test_results, [:account_id, :career_test_id, :created_at],
              :name => :index_career_test_results_on_account_career_created
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO career_test_results (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM career_test_results WHERE id = 1000")
    
  end

  def self.down
    drop_table :career_test_results
  end
end

