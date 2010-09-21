class AddSalesOpportunityComments < ActiveRecord::Migration
  def self.up
    
    # sales_opportunity_comments table
    create_table :sales_opportunity_comments, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :opportunity_id, :integer
      
      t.column :account_id, :integer
      t.column :content, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :sales_opportunity_comments, [:opportunity_id, :created_at],
              :name => :index_sales_opportunity_comments_on_opportunity_created
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO sales_opportunity_comments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM sales_opportunity_comments WHERE id = 1000")
    
  end

  def self.down
    drop_table :sales_opportunity_comments
  end
end
