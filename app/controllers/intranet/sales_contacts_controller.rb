module Intranet
  class SalesContactsController < ApplicationController
  
    layout "community"
  
    before_filter :check_login
    before_filter :check_employee
    before_filter :check_limited, :only => []
  
  
  
    def index
      page = params[:page]
      page = 1 unless page =~ /\d+/

      @contacts = SalesContact.paginate(
        :page => page,
        :per_page => 20,
        :select => "id, name, gender, company, title, mobile, phone, email, account_id, created_at",
        :conditions => ["account_id = ?", @employee[:account_id]],
        :order => "created_at DESC"
      )
    end
    
    
    def new
      @contact = SalesContact.new(:account_id => session[:account_id], :updated_by => session[:account_id])
    end
    
    def create
      @contact = SalesContact.new(:account_id => session[:account_id], :updated_by => session[:account_id])
      
      @contact.name = params[:name] && params[:name].strip
      @contact.gender = case params[:gender]
        when "true"
          true
        when "false"
          false
        else
          nil
      end
      @contact.company = params[:company] && params[:company].strip
      @contact.title = params[:title] && params[:title].strip
      
      @contact.mobile = params[:mobile] && params[:mobile].strip
      @contact.phone = params[:phone] && params[:phone].strip
      @contact.fax = params[:fax] && params[:fax].strip
      @contact.email = params[:email] && params[:email].strip
      
      @contact.address = params[:address] && params[:address].strip
      @contact.zip = params[:zip] && params[:zip].strip
      
      @contact.notes = params[:notes] && params[:notes].strip

      if @contact.save
        return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_contacts/#{@contact.id}")
      end

      render :action => "new"
    end
  
  
    def show
      @contact = SalesContact.find(params[:id])
    end
    
    
    def edit
      @contact = SalesContact.find(params[:id])
    end
    
    def update
      @contact = SalesContact.find(params[:id])
      
      @contact.updated_by = session[:account_id]
      
      @contact.name = params[:name] && params[:name].strip
      @contact.gender = case params[:gender]
        when "true"
          true
        when "false"
          false
        else
          nil
      end
      @contact.company = params[:company] && params[:company].strip
      @contact.title = params[:title] && params[:title].strip
      
      @contact.mobile = params[:mobile] && params[:mobile].strip
      @contact.phone = params[:phone] && params[:phone].strip
      @contact.fax = params[:fax] && params[:fax].strip
      @contact.email = params[:email] && params[:email].strip
      
      @contact.address = params[:address] && params[:address].strip
      @contact.zip = params[:zip] && params[:zip].strip
      
      @contact.notes = params[:notes] && params[:notes].strip
      
      if @contact.save
        return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_contacts/#{@contact.id}")
      end

      render :action => "edit"
    end
  
  
  
    private
  
  
  
  end
end