class GraphsController < ApplicationController
  before_filter  :get_programs
  before_filter  :get_investigators
  before_filter  :find_last_load_date
  before_filter  :initialize_years

  verify :only => [ 'member', 'member_nodes' ],	:params => [:id],
  :method => 'get',
  :add_flash => { :notice => 'Please specify provide an username for interaction graph.' },
  :redirect_to => { :controller => 'abstracts' }

  verify :only => [ 'program', 'program_nodes' ],	:params => [:id],
  :method => 'get',
  :add_flash => { :notice => 'A program id is required for interaction graphs.' },
  :redirect_to => { :controller => 'abstracts' }

  def index

  end

  def program
     if !@program = Program.find_by_id(params[:id])
        flash[:notice] = 'Invalid program id specified for interaction graph.'
        params[:id] = nil
        redirect_to :controller => 'abstracts'
     end
  end


  def member
     if !@investigator = Investigator.find_by_username(params[:id])
        flash[:notice] = 'Unknown username specified for interaction graph.'
        params[:id] = nil
        redirect_to :controller => 'abstracts'
     end
  end


  def program_nodes
     @program = Program.find(params[:id])

     @investigators = Investigator.find :all,
     :order => 'last_name ASC, first_name ASC',
     :include => ['current_programs'],
     :conditions => ['programs.id = :program_id',
     {:program_id => params[:id]}]

     if session[:years].show_all?
       Investigator.get_connections(@investigators)
     else
       Investigator.get_connections(@investigators, session[:years].starting, session[:years].ending)
     end

     respond_to do |format|
        format.xml
     end
  end
  

  def member_nodes
#     @investigator = Investigator.find( :first, :include => ['investigator_programs'], 
#     :conditions => ['investigators.username = :username', {:username => params[:id]}])

    @investigator = Investigator.username(params[:id]).first
     
     if session[:years].show_all?
       Investigator.get_investigator_connections(@investigator)
        @publication_count = @investigator.abstracts.count.to_s
     else
       Investigator.get_investigator_connections(@investigator, session[:years].starting, session[:years].ending)  
       @publication_count = @investigator.abstracts.count( :conditions => [ 'year BETWEEN :start_year AND :end_year',
       {:end_year => session[:years].ending, :start_year => session[:years].starting} ]).to_s
     end

     respond_to do |format|
        format.xml
     end
  end
end
