module Intranet
  class SalesContactsController < ApplicationController
  
    layout "uncategoried"
  
    before_filter :check_login
    before_filter :check_employee
    before_filter :check_limited, :only => []
  
  
  
    def index
    
    end
  
  
    def show
    
    end
  
  
  
    private
  
  
  
  end
end