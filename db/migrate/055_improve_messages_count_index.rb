class ImproveMessagesCountIndex < ActiveRecord::Migration
  def self.up
    
    add_index :sys_messages, [:account_id, :has_read]
    
    add_index :messages, [:receiver_id, :has_read]
    
  end

  def self.down
    
    remove_index :messages, [:receiver_id, :has_read]
    
    remove_index :sys_messages, [:account_id, :has_read]
    
  end
end

