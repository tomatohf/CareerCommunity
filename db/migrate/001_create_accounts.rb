class CreateAccounts < ActiveRecord::Migration
  def self.up
    
    # accounts table
    create_table :accounts, :force => true do |t|
      t.column :email, :string
      t.column :password, :string
      
      t.column :nick, :string
      t.column :timezone_id, :integer # foreign key of Timezone
      
      # if checked && active == false
      #   the account can view but is limited to take any action
      # end
      t.column :checked, :boolean, :default => false # if checked is false, the account need to be verified
      t.column :active, :boolean, :default => true # if active is false, the account equals to be un-checked
      t.column :enabled, :boolean, :default => true # if enabled is false, the account equals to be deleted
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :accounts, :email, :unique => true
    add_index :accounts, :enabled
    add_index :accounts, :delta
    # reserve first 1000 ID
    ActiveRecord::Base.connection.execute("INSERT INTO accounts (id) VALUES (1000)")
    ActiveRecord::Base.connection.execute("DELETE FROM accounts WHERE id = 1000")
    
    # ----------
    
    # timezones table
    # NOTE:
    # The rails timezone class is named TimeZone
    # While our timezone class is named Timezone
    # notice the case of the letter z
    create_table :timezones, :force => true do |t|
      t.column :name, :string
      t.column :offset, :integer # the number of seconds that this time zone is offset from UTC (GMT)
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :timezones, :name
    add_index :timezones, :delta
    
    # initialize timezone data
    Timezone.delete_all
    TimeZone.all.each { |tz| Timezone.create(:name => tz.name, :offset => tz.utc_offset) }
    
    # ----------
    
    # roles table
    create_table :roles, :force => true do |t|
      t.column :name, :string
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :roles, :name
    add_index :roles, :delta
    
    # initialize roles table data
    Role.delete_all
    [Role.admin_name].each { |r| Role.create(:name => r) }
    
    # roles table
    # a role is associated only when special access is required, such as admin privilege
    # normal account has no need and actually doesn't have a role associated
    create_table :accounts_roles, :id => false, :force => true do |t|
      t.column :account_id, :integer
      t.column :role_id, :integer
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :accounts_roles, [:account_id, :role_id]
    add_index :accounts_roles, :delta
    
    # ----------
    
    # autologins table
    create_table :autologins, :force => true do |t|
      t.column :session_id, :string
      t.column :account_id, :integer

      t.column :expire_time, :datetime
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :autologins, :account_id
    add_index :autologins, :delta
    
    # ----------
    
    # account_settings table
    create_table :account_settings, :force => true do |t|
      t.column :account_id, :integer
      
      t.column :setting, :text

      t.column :updated_at, :datetime
      
      
      # enable sphinx delta index
      t.column :delta, :boolean
    end
    add_index :account_settings, :account_id
    add_index :account_settings, :delta

  end

  def self.down
    drop_table :account_settings
    drop_table :autologins
    drop_table :accounts_roles
    drop_table :roles
    drop_table :timezones
    drop_table :accounts
  end
end
