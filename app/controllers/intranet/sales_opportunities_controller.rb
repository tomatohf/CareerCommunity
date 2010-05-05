module Intranet
  class SalesOpportunitiesController < ApplicationController
    
    Opportunity_Page_Size = 20
    
  
    layout "community"
  
    before_filter :check_login
    before_filter :check_employee
    before_filter :check_limited, :only => [:create, :update, :update_step_done,
                                            :create_attachment, :delete_attachment,
                                            :create_record, :update_record, :delete_record]
    
    before_filter :check_opportunity, :except => [:index, :fail, :success,
                                                  :new, :create]
    before_filter :check_attachment, :only => [:attachment, :delete_attachment]
    before_filter :check_record, :only => [:edit_record, :update_record, :delete_record]
  
  
  
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
      @opportunity = SalesOpportunity.new
      @contact_name = params[:contact]
    end
    
    def create
      @opportunity = SalesOpportunity.new(:status_id => SalesOpportunityStatus.find_by(:name, "ongoing")[:id])
      
      if save_opportunity
        return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_opportunities/#{@opportunity.id}")
      end

      render :action => "new"
    end
    
    
    def edit
      @contact_name = @contact.name
    end
    
    def update
      if save_opportunity
        return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_opportunities/#{@opportunity.id}")
      end
      
      render :action => "edit"
    end
    
    
    def update_step_done
      @step_record = SalesOpportunityStepRecord.get_record(@opportunity.id, params[:step_id])
      @step_record.done = (params[:done] == "true")
      
      @step_record.save!
      
      render :nothing => true
    end
  
  
    def show
      @step_records = SalesOpportunityStepRecord.find(
        :all,
        :conditions => ["opportunity_id = ?", @opportunity]
      )
      
      @attachments = SalesOpportunityAttachment.find(
        :all,
        :conditions => ["opportunity_id = ?", @opportunity],
        :order => "updated_at DESC"
      )
      
      @records = SalesOpportunityRecord.find(
        :all,
        :conditions => ["opportunity_id = ?", @opportunity],
        :order => "occur_at DESC"
      )
    end
    
    
    def new_attachment
      @attachment = SalesOpportunityAttachment.new
    end
    
    def create_attachment
      @attachment = SalesOpportunityAttachment.new(
        :opportunity_id => @opportunity.id,
        :desc => params[:attachment_desc] && params[:attachment_desc].strip
      )
      @attachment.attachment = params[:attachment_file]

      if @attachment.save
        return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_opportunities/#{@opportunity.id}")
      else
        flash.now[:error_msg] = "操作失败, 再试一次吧"
      end

      render :action => "new_attachment"
    end
    
    def attachment
      file_name = @attachment.attachment_file_name
      file_name = URI.encode(file_name) if (request.env["HTTP_USER_AGENT"] || "") =~ /MSIE/i

      if Rails.env.production?
        # invoke the x-sendfile of lighttpd to download file
        response.headers["Content-Type"] = @attachment.attachment_content_type
        response.headers["Content-Disposition"] = %Q!attachment; filename=#{file_name}!
        response.headers["Content-Length"] = @attachment.attachment_file_size
        response.headers["X-LIGHTTPD-send-file"] = @attachment.attachment.path
        # response.headers["X-sendfile"] = @attachment.attachment.path
        render :nothing => true
      else
        send_file(
          @attachment.attachment.path,
          :type => @attachment.attachment_content_type,
          :disposition => %Q!attachment; filename=#{file_name}!
        )
      end
    end
    
    def delete_attachment
      @attachment.destroy
      
      jump_to("/intranet/employees/#{@employee[:account_id]}/sales_opportunities/#{@opportunity.id}")
    end
    
    
    def new_record
      @record = SalesOpportunityRecord.new
    end
    
    def create_record
      @attachment = SalesOpportunityAttachment.new(
        :opportunity_id => @opportunity.id,
        :desc => params[:attachment_desc] && params[:attachment_desc].strip
      )
      @attachment.attachment = params[:attachment_file]

      if @attachment.save
        return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_opportunities/#{@opportunity.id}")
      else
        flash.now[:error_msg] = "操作失败, 再试一次吧"
      end

      render :action => "new_attachment"
    end
  
  
  
    private
    
    def check_opportunity
      @opportunity = SalesOpportunity.find(params[:id])
      @contact = SalesContact.find(@opportunity.contact_id)
      
      jump_to("/errors/unauthorized") unless @employee[:account_id] == @contact.account_id
    end
    
    def check_attachment
      @attachment = SalesOpportunityAttachment.find(params[:attachment_id])
      jump_to("/errors/unauthorized") unless @attachment.opportunity_id == @opportunity.id
    end
    
    def check_record
      @record = SalesOpportunityRecord.find(params[:record_id])
      jump_to("/errors/unauthorized") unless @record.opportunity_id == @opportunity.id
    end
  
    def save_opportunity
      @opportunity.title = params[:title] && params[:title].strip
      
      contact = SalesContact.find(
        :all,
        :select => "id, name",
        :conditions => ["name = ?", params[:contact] && params[:contact].strip]
      ).select { |contact| contact.account_id = @employee[:account_id] }.first
      
      if contact
        @contact_name = contact.name
        
        @opportunity.contact_id = contact.id
        return @opportunity.save
      else
        @contact_name = @contact && @contact.name
        
        flash.now[:error_msg] = "输入的客户姓名不存在"
      end
      
      false
    end
  
  end
end
