class VoteTopicAllowAnonymous < ActiveRecord::Migration
  def self.up

    add_column :vote_topics, :allow_anonymous, :boolean, :default => false
    add_index :vote_topics, :allow_anonymous
    
  end



  def self.down
    remove_column :vote_topics, :allow_anonymous
  end
end
