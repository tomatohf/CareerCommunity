module Intranet
  class EmployeesController < ApplicationController
    
    layout "community"
  
    before_filter :check_login
    before_filter :check_manager
    # before_filter :check_limited, :only => []
  
  
  
    def index
      @employees = Employee.data.select { |employee| employee[:account_id] != session[:account_id] }
    end
  
  
  
    private
  
    def check_manager
      employee = Intranet::Employee.find_by(:account_id, session[:account_id])
      
      jump_to("/errors/forbidden") unless employee && employee[:manager]
    end
  
  end
end