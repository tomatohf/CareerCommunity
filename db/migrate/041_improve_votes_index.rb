class ImproveVotesIndex < ActiveRecord::Migration
  def self.up
    
    remove_index :vote_categories, :name
    
    
    # remove_index :vote_topics, :created_at
    remove_index :vote_topics, :account_id
    remove_index :vote_topics, :category_id
    remove_index :vote_topics, :multiple
    remove_index :vote_topics, :allow_add_option
    remove_index :vote_topics, :allow_anonymous
    
    add_index :vote_topics, [:account_id, :created_at]
    add_index :vote_topics, [:category_id, :created_at]
    add_index :vote_topics, [:group_id, :created_at]
    
    
    # remove_index :vote_images, :vote_topic_id
    remove_index :vote_images, :photo_id
    
    
    remove_index :vote_options, :created_at
    remove_index :vote_options, :account_id
    # remove_index :vote_options, :vote_topic_id
    remove_index :vote_options, :color
    
    
    remove_index :vote_records, :created_at
    remove_index :vote_records, :updated_at
    remove_index :vote_records, :account_id
    remove_index :vote_records, :vote_topic_id
    # remove_index :vote_records, :vote_option_id
    remove_index :vote_records, :voter_ip
    
    add_index :vote_records, [:vote_topic_id, :account_id, :voter_ip]
    
    
    remove_index :vote_comments, :vote_topic_id
    remove_index :vote_comments, :account_id
    remove_index :vote_comments, :created_at
    
    add_index :vote_comments, [:vote_topic_id, :created_at]
    
  end

  def self.down
    
    remove_index :vote_comments, [:vote_topic_id, :created_at]
    
    add_index :vote_comments, :vote_topic_id
    add_index :vote_comments, :account_id
    add_index :vote_comments, :created_at
    
    
    remove_index :vote_records, [:vote_topic_id, :account_id, :voter_ip]
    
    add_index :vote_records, :created_at
    add_index :vote_records, :updated_at
    add_index :vote_records, :account_id
    add_index :vote_records, :vote_topic_id
    # add_index :vote_records, :vote_option_id
    add_index :vote_records, :voter_ip
    
    
    add_index :vote_options, :created_at
    add_index :vote_options, :account_id
    # add_index :vote_options, :vote_topic_id
    add_index :vote_options, :color
    
    
    # add_index :vote_images, :vote_topic_id
    add_index :vote_images, :photo_id
    
    
    remove_index :vote_topics, [:group_id, :created_at]
    remove_index :vote_topics, [:category_id, :created_at]
    remove_index :vote_topics, [:account_id, :created_at]
    
    # add_index :vote_topics, :created_at
    add_index :vote_topics, :account_id
    add_index :vote_topics, :category_id
    add_index :vote_topics, :multiple
    add_index :vote_topics, :allow_add_option
    add_index :vote_topics, :allow_anonymous
    
    
    add_index :vote_categories, :name
    
  end
end

