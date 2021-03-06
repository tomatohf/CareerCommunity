module Intranet
  class SalesContactsController < ApplicationController
    
    Contact_Page_Size = 20
    
  
    layout "community"
  
    before_filter :check_login
    before_filter :check_employee
    before_filter :check_limited, :only => [:create, :update, :update_account]
    before_filter :check_contact, :except => [:index, :search, :new, :create]
                                                  
    before_filter :check_not_manager, :only => [:new, :create, :edit, :update,
                                                :edit_account, :update_account]
  
  
  
    def index
      page = params[:page]
      page = 1 unless page =~ /\d+/

      @contacts = SalesContact.paginate(
        :page => page,
        :per_page => Contact_Page_Size,
        :select => "id, name, gender, company, title, mobile, phone, account_id, created_at",
        :conditions => ["account_id = ?", @employee[:account_id]],
        :order => "created_at DESC"
      )
    end
    
    
    def search
      @contact_name = params[:contact_name] && params[:contact_name].strip

      return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_contacts") if @contact_name.blank?

      @contacts = SalesContact.find(
        :all,
        :select => "id, name, gender, company, title, mobile, phone, email, account_id, created_at",
        :conditions => ["name like ?", "#{@contact_name}%"]
      ).select { |contact| contact.account_id == @employee[:account_id] }
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
      
    end
    
    
    def edit
      
    end
    
    def update
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
    
    
    def edit_account
      
    end
    
    def update_account
      @contact.updated_by = session[:account_id]
      
      employee = Intranet::Employee.find_by(:account_id, params[:account_id].to_i)
      return jump_to("/errors/unauthorized") unless employee

      @contact.account_id = employee[:account_id]
      
      if @contact.save
        return jump_to("/intranet/employees/#{@employee[:account_id]}/sales_contacts")
      end

      render :action => "edit_account"
    end
  
  
  
    private
    
    def check_contact
      @contact = SalesContact.find(params[:id])
      
      jump_to("/errors/unauthorized") unless @employee[:account_id] == @contact.account_id
    end
  
    def check_not_manager
      jump_to("/errors/forbidden") if @manager
    end
  
  end
end