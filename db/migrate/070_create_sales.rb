class CreateSales < ActiveRecord::Migration
  def self.up
    
    # sales_contacts table
    create_table :sales_contacts, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :account_id, :integer
      t.column :updated_by, :integer
      
      
      t.column :name, :string, :limit => 25
      t.column :gender, :boolean
      t.column :company, :string, :limit => 50
      t.column :title, :string, :limit => 25
      
      t.column :mobile, :string, :limit => 20
      t.column :phone, :string, :limit => 20
      t.column :fax, :string, :limit => 20
      t.column :email, :string
      
      t.column :address, :string
      t.column :zip, :string, :limit => 10
      
      t.column :notes, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :sales_contacts, [:account_id, :created_at]
    add_index :sales_contacts, :name
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO sales_contacts (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM sales_contacts WHERE id = 1000")
    
    
    # sales_opportunities table
    create_table :sales_opportunities, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :contact_id, :integer
      t.column :status_id, :integer, :limit => 1
      t.column :title, :string, :limit => 50
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :sales_opportunities, [:contact_id, :status_id]
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO sales_opportunities (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM sales_opportunities WHERE id = 1000")
    
    
    # sales_opportunity_step_records table
    create_table :sales_opportunity_step_records, :force => true do |t|
      t.column :updated_at, :datetime
      
      t.column :opportunity_id, :integer
      t.column :step_id, :integer, :limit => 2
      
      t.column :done, :boolean, :default => false
      t.column :notes, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :sales_opportunity_step_records, [:opportunity_id, :step_id],
              :name => :index_sales_opportunity_step_records_on_opportunity_and_step,
              :unique => true
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO sales_opportunity_step_records (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM sales_opportunity_step_records WHERE id = 1000")
    
    
    # sales_opportunity_records table
    create_table :sales_opportunity_records, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :opportunity_id, :integer
      t.column :occur_at, :datetime
      t.column :notes, :string, :limit => 1000
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :sales_opportunity_records, [:opportunity_id, :occur_at],
              :name => :index_sales_opportunity_records_on_opportunity_occur
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO sales_opportunity_records (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM sales_opportunity_records WHERE id = 1000")
    
    
    # sales_opportunity_attachments table
    create_table :sales_opportunity_attachments, :force => true do |t|
      t.column :updated_at, :datetime
      
      t.column :opportunity_id, :integer
      
      t.column :desc, :string, :limit => 100
      

      # for paperclip ...
      t.column :attachment_file_name, :string # Original filename
      t.column :attachment_content_type, :string # Mime type
      t.column :attachment_file_size, :integer # File size in bytes
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :sales_opportunity_attachments, [:opportunity_id, :updated_at],
              :name => :index_sales_opportunity_attachments_on_opportunity_updated
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO sales_opportunity_attachments (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM sales_opportunity_attachments WHERE id = 1000")
    
    
    # sales_opportunity_todos table
    create_table :sales_opportunity_todos, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :opportunity_id, :integer
      t.column :done, :boolean, :default => false
      
      t.column :title, :string, :limit => 100
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :sales_opportunity_todos, [:opportunity_id, :done, :created_at],
              :name => :index_sales_opportunity_todos_on_opportunity_done_created
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO sales_opportunity_todos (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM sales_opportunity_todos WHERE id = 1000")
    
  end

  def self.down
    drop_table :sales_opportunity_todos
    drop_table :sales_opportunity_attachments
    drop_table :sales_opportunity_records
    drop_table :sales_opportunity_step_records
    drop_table :sales_opportunities
    drop_table :sales_contacts
  end
end
