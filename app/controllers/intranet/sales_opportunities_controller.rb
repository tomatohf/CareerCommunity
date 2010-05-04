module Intranet
  class SalesOpportunitiesController < ApplicationController
    
    Opportunity_Page_Size = 20
    
  
    layout "community"
  
    before_filter :check_login
    before_filter :check_employee
    before_filter :check_limited, :only => [:create, :update]
  
  
  
    def index
      @status = SalesOpportunityStatus.find_by(:name, "ongoing")
      
      @opportunities = SalesOpportunity.find(
        :all,
        :joins => "INNER JOIN sales_contacts ON sales_contacts.id = sales_opportunities.contact_id",
        :conditions => [
          "sales_contacts.account_id = ? and sales_opportunities.status_id = ?",
          @employee[:account_id],
          @status[:id]
        ],
        :include => [:contact, :step_records]
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
    
    
    def new
      @opportunity = SalesOpportunity.new(:contact_id => params[:contact])
    end
    
    def create
      @opportunity = SalesOpportunity.new(:status_id => SalesOpportunityStatus.find_by(:name, "ongoing")[:id])
      
      if save_opportunity
        return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_opportunities/#{@opportunity.id}")
      end

      render :action => "new"
    end
    
    
    def edit
      @opportunity = SalesOpportunity.find(params[:id])
    end
    
    def update
      @opportunity = SalesOpportunity.find(params[:id])
      
      if save_opportunity
        return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_opportunities/#{@opportunity.id}")
      end
      
      render :action => "edit"
    end
  
  
    def show
      @opportunity = SalesOpportunity.find(params[:id])
      @contact = SalesContact.find(@opportunity.contact_id)
    end
  
  
  
    private
  
    def save_opportunity
      @opportunity.title = params[:title] && params[:title].strip
      
      contact = SalesContact.find(
        :all,
        :select => "id, name",
        :conditions => ["name = ?", params[:contact] && params[:contact].strip]
      ).select { |contact| contact.account_id = @employee[:account_id] }.first
      
      if contact
        @opportunity.contact_id = contact.id
        
        return @opportunity.save
      else
        flash.now[:error_msg] = "输入的客户姓名不存在"
      end
      
      false
    end
  
  end
end
