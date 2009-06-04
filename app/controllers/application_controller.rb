# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  include ExceptionNotifiable
  
  def logout
    reset_session
    redirect_to :controller => "/login", :done => 1
  end

  def year_change 
    if params[:all] == 'yes'
      session[:years].show_all = true
      session[:years].starting = session[:years].first
      session[:years].ending = session[:years].last
    else
      session[:years].show_all = false
      session[:years].starting = params[:years][:start]
      session[:years].ending = params[:years][:end]
    end
    
    if params[:location] == '/abstracts/search'
      session[:search] = nil
      redirect_to '/'
    else
      redirect_to params[:location]
    end
    
  end

  protected
    
  def authenticate        
    unless session[:user]
      session[:return_to] = request.request_uri
      redirect_to :controller => "/login" 
      return false
    end
  end  

  def get_programs
    @programs = Program.all :select => 'id, program_title', :order => "program_number"
  end
  
  def get_investigators
    @investigators = Investigator.all :select => 'username, first_name, last_name, middle_name', :order => "last_name ASC"
  end
   
  def find_last_load_date
     s = Setting.first
     @last_load_date = s.last_update.strftime("%A, %B %d, %Y")
  end
  
  def initialize_years    
    if session[:years].nil?
      s = Setting.first
      start_year = s.start_year
      end_year = s.end_year 
      session[:years] = Years.new(start_year, end_year)
      session[:years].starting = session[:years].ending - 5
    end
  end
end
