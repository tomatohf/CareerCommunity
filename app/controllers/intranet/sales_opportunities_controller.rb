module Intranet
  class SalesOpportunitiesController < ApplicationController
    
    Opportunity_Page_Size = 20
    
  
    layout "community"
  
    before_filter :check_login
    before_filter :check_employee
    before_filter :check_limited, :only => []
  
  
  
    def index
      @status = SalesOpportunityStatus.find_by(:name, "ongoing")
      
      @opportunities = SalesOpportunity.find(
        :all,
        :joins => "INNER JOIN sales_contacts ON sales_contacts.id = sales_opportunities.contact_id",
        :conditions => [
          "sales_contacts.account_id = ? and sales_opportunities.status_id = ?",
          @employee[:account_id],
          @status[:id]
        ]
      )
    end
    
    def fail
      @status = SalesOpportunityStatus.find_by(:name, "fail")
      
      page = params[:page]
      page = 1 unless page =~ /\d+/
      
      @opportunities = SalesOpportunity.paginate(
        :page => page,
        :per_page => Opportunity_Page_Size,
        :conditions => ["status_id = ?", @employee[:account_id]],
        :order => "created_at DESC"
      )
    end
    
    def success
      @status = SalesOpportunityStatus.find_by(:name, "success")
    end
  
  
    def show
    
    end
  
  
  
    private
  
  
  
  end
end
