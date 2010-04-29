module Intranet
  class SalesOpportunitiesController < ApplicationController
  
    layout "community"
  
    before_filter :check_login
    before_filter :check_employee
    before_filter :check_limited, :only => []
  
  
  
    def index
      @contacts = SalesContact
    end
  
  
    def show
    
    end
  
  
  
    private
  
  
  
  end
end
