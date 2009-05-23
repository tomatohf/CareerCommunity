class ImproveFriendsIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :sys_messages, :account_id
    remove_index :sys_messages, :created_at
    remove_index :sys_messages, :has_read
    remove_index :sys_messages, :msg_type
    
    add_index :sys_messages, [:account_id, :created_at]
    
    
    remove_index :sent_messages, :created_at
    remove_index :sent_messages, :sender_id
    remove_index :sent_messages, :receiver_id
    remove_index :sent_messages, :reply_to_id
    
    add_index :sent_messages, [:sender_id, :created_at], :unique => true
    add_index :sent_messages, [:reply_to_id, :sender_id, :receiver_id]
    
    
    remove_index :messages, :receiver_id
    remove_index :messages, :created_at
    remove_index :messages, :sender_id
    remove_index :messages, :has_read
    remove_index :messages, :reply_to_id
    
    add_index :messages, [:receiver_id, :created_at]
    add_index :messages, [:reply_to_id, :receiver_id, :sender_id]
    
    
    remove_index :friends, [:account_id, :friend_id]
    # remove_index :friends, :account_id
    # remove_index :friends, :friend_id
    
    
    remove_index :space_comments, :owner_id
    remove_index :space_comments, :account_id
    remove_index :space_comments, :created_at
    
    add_index :space_comments, [:owner_id, :created_at]
    
    
    remove_index :account_actions, :account_id
    remove_index :account_actions, :created_at
    remove_index :account_actions, :action_type
    remove_index :account_actions, :hide
    
    add_index :account_actions, [:hide, :created_at]
    add_index :account_actions, [:hide, :account_id, :created_at]
    add_index :account_actions, [:hide, :account_id, :action_type, :created_at],
              :name => :index_account_actions_on_hide_account_type_created_at
    
  end

  def self.down
    
    remove_index :account_actions, :name => :index_account_actions_on_hide_account_type_created_at
    remove_index :account_actions, [:hide, :account_id, :created_at]
    remove_index :account_actions, [:hide, :created_at]
    
    add_index :account_actions, :account_id
    add_index :account_actions, :created_at
    add_index :account_actions, :action_type
    add_index :account_actions, :hide
    
    
    remove_index :space_comments, [:owner_id, :created_at]
    
    add_index :space_comments, :owner_id
    add_index :space_comments, :account_id
    add_index :space_comments, :created_at
    
    
    # add_index :friends, :account_id
    # add_index :friends, :friend_id
    add_index :friends, [:account_id, :friend_id]
    
    
    remove_index :messages, [:reply_to_id, :receiver_id, :sender_id]
    remove_index :messages, [:receiver_id, :created_at]
    
    add_index :messages, :created_at
    add_index :messages, :receiver_id
    add_index :messages, :sender_id
    add_index :messages, :has_read
    add_index :messages, :reply_to_id
    
    
    remove_index :sent_messages, [:reply_to_id, :sender_id, :receiver_id]
    remove_index :sent_messages, [:sender_id, :created_at]
    
    add_index :sent_messages, :created_at
    add_index :sent_messages, :sender_id
    add_index :sent_messages, :receiver_id
    add_index :sent_messages, :reply_to_id
    
    
    remove_index :sys_messages, [:account_id, :created_at]
    
    add_index :sys_messages, :account_id
    add_index :sys_messages, :created_at
    add_index :sys_messages, :has_read
    add_index :sys_messages, :msg_type
    
  end
end

