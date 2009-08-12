class AddCompaniesTalksIndex < ActiveRecord::Migration
  def self.up
    
    add_index :talks_companies, [:company_id, :talk_id], :unique => true
    
  end

  def self.down
    remove_index :talks_companies, [:company_id, :talk_id]
  end
end

