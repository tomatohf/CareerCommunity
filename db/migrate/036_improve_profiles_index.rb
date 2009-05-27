class ImproveProfilesIndex < ActiveRecord::Migration
  def self.up
    
    # remove_index :basic_profiles, :account_id
    remove_index :basic_profiles, :birthday
    remove_index :basic_profiles, :real_name
    remove_index :basic_profiles, :province_id
    remove_index :basic_profiles, :city_id
    remove_index :basic_profiles, :hometown_province_id
    remove_index :basic_profiles, :hometown_city_id
    
    
    # remove_index :contact_profiles, :account_id
    
    
    # remove_index :hobby_profiles, :account_id
    
    
    remove_index :education_profiles, :account_id
    remove_index :education_profiles, :education_id
    remove_index :education_profiles, :enter_year
    
    add_index :education_profiles, :edu_name
    add_index :education_profiles, [:account_id, :education_id, :enter_year],
              :name => :index_edu_profiles_on_account_edu_year
    
    
    remove_index :job_profiles, :account_id
    remove_index :job_profiles, :profession_id
    remove_index :job_profiles, :enter_year
    remove_index :job_profiles, :enter_month
    
    add_index :job_profiles, :job_name
    add_index :job_profiles, [:account_id, :enter_year, :enter_month],
              :name => :index_job_profiles_on_account_year_month
    
    
    # remove_index :point_profiles, :account_id
    remove_index :point_profiles, :points
    remove_index :point_profiles, :exp
    
    
    # remove_index :pic_profiles, :account_id
    remove_index :pic_profiles, :photo_id
    
  end

  def self.down
    
    # add_index :pic_profiles, :account_id
    add_index :pic_profiles, :photo_id
    
    
    # add_index :point_profiles, :account_id
    add_index :point_profiles, :points
    add_index :point_profiles, :exp
    
    
    remove_index :job_profiles, :name => :index_job_profiles_on_account_year_month
    remove_index :job_profiles, :job_name
    
    add_index :job_profiles, :account_id
    add_index :job_profiles, :profession_id
    add_index :job_profiles, :enter_year
    add_index :job_profiles, :enter_month
    
    
    remove_index :education_profiles, :name => :index_edu_profiles_on_account_edu_year
    remove_index :education_profiles, :edu_name
    
    add_index :education_profiles, :account_id
    add_index :education_profiles, :education_id
    add_index :education_profiles, :enter_year
    
    
    # add_index :hobby_profiles, :account_id
    
    
    # add_index :contact_profiles, :account_id
    
    
    # add_index :basic_profiles, :account_id
    add_index :basic_profiles, :birthday
    add_index :basic_profiles, :real_name
    add_index :basic_profiles, :province_id
    add_index :basic_profiles, :city_id
    add_index :basic_profiles, :hometown_province_id
    add_index :basic_profiles, :hometown_city_id
    
  end
end

