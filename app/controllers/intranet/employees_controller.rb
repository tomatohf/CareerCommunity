module Intranet
  class EmployeesController < ApplicationController
    
    Contact_Page_Size = 30
    
    
    layout "community"
  
    before_filter :check_login
    before_filter :check_manager
    # before_filter :check_limited, :only => []
  
  
  
    def index
      @employees = Employee.data.select { |employee| employee[:account_id] != session[:account_id] }
    end
    
    
    def contacts
      page = params[:page]
      page = 1 unless page =~ /\d+/

      @contacts = SalesContact.paginate(
        :page => page,
        :per_page => Contact_Page_Size,
        :select => "id, name, gender, company, title, mobile, phone, account_id, created_at",
        :order => "name ASC"
      )
    end
    
    def search_contacts
      @contact_name = params[:contact_name] && params[:contact_name].strip

      return jump_to("/intranet/employees/contacts") if @contact_name.blank?

      @contacts = SalesContact.find(
        :all,
        :select => "id, name, gender, company, title, mobile, phone, email, account_id, created_at",
        :conditions => ["name like ?", "#{@contact_name}%"]
      )
    end
  
  
  
    private
  
    def check_manager
      employee = Employee.find_by(:account_id, session[:account_id])
      
      jump_to("/errors/forbidden") unless employee && employee[:manager]
    end
  
  end
end