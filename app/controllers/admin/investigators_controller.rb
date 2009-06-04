class Admin::InvestigatorsController < ApplicationController
  
  before_filter :authenticate

  verify :only => [ 'destroy', 'edit', 'show' ],
  :params => :id,
  :add_flash => { :notice => 'Missing Investigator ID.' },
  :redirect_to => { :action => 'list' }

  verify :only => [ 'create' ],	:params => [:investigator],
  :method => 'post',
  :add_flash => { :notice => 'Please specify an investigator.' },
  :redirect_to => { :action => 'new' }

  verify :only => [ 'update' ],	:params => [:investigator],
  :method => 'post',
  :add_flash => { :notice => 'Please specify an investigator.' },
  :redirect_to => { :action => 'edit' }


  def index
     list
     render :action => 'list'
  end

  def list
     @investigators = Investigator.paginate(:page => params[:page] || 1,
     :per_page => 40,
     :select => 'username, first_name, last_name, middle_name, id',
     :order => "last_name ASC, first_name ASC"
     )
  end

  def show
     @investigator = Investigator.find(params[:id])
  end

  def edit
     @investigator = Investigator.find(params[:id])
     programs
  end

  def update

     redirect_to :action => 'list' and return if params[:commit] == 'Cancel'

     @investigator = Investigator.find(params[:id])

     if @investigator.update_attributes(params[:investigator])

        InvestigatorProgram.delete_all "investigator_id = #{@investigator.id}"

        if params[:programs]
           params[:programs].each do |program_id|
              @investigator.investigator_programs.create(
              :investigator_id => @investigator,
              :program_id => program_id,
              :program_appointment => 'member',
              :start_date => Time.now
              )
           end
        end

        flash[:notice] = @investigator.fullname + " successfully modified."
        redirect_to :action => "show", :id => @investigator
     else
        @investigator = Investigator.new(params[:investigator])
        programs
        render :action => "edit"
     end
  end

  def new
     @investigator = Investigator.new(params[:investigator])
     programs
  end

  def create
     redirect_to :action => 'list' and return if params[:commit] == 'Cancel'

     if params[:commit] == 'Search'
        @investigator = Investigator.new
        @investigator.username = params[:investigator][:username]

        begin

           if Investigator.find(:first, :conditions => ['username = ?', @investigator.username])
              raise "#{@investigator.username} is already in the system."
           end

           ldap = MyLDAP.new(CONFIG[:ldap])

           if person = ldap.get_person(@investigator.username)

              if person['sn']
                 @investigator.last_name = person['sn']
              end

              if person['mail']
                 @investigator.email = person['mail']
              end

              if person['givenname']
                 @investigator.first_name = person['givenname']
              end

              if person['initials']
                 @investigator.middle_name = person['initials']
              end

           else
              raise "Unable to find #{@investigator.username} in LDAP."
           end

        rescue Exception => ex
           flash[:error] = ex
        end

        programs
        render :action => 'new'

     else
        @investigator = Investigator.new(params[:investigator])

        if @investigator.save

           if params[:programs]
              params[:programs].each do |program_id|
                 @investigator.investigator_programs.create(
                 :investigator_id => @investigator,
                 :program_id => program_id,
                 :program_appointment => 'member',
                 :start_date => Time.now
                 )
              end
           end

           flash[:notice] = @investigator.fullname + " successfully created."
           redirect_to :action => "show", :id => @investigator
        else
           render :action => "new"
        end
     end
  end

  def destroy
     investigator = Investigator.find(params[:id])
     name = investigator.fullname

     if investigator.destroy
        flash[:notice] = name + " was successfully removed."
     else
        flash[:error] = 'Failed to remove ' + name
     end

     redirect_to :action => 'list'
  end

  private

  def programs
     @programs = Program.find :all, :order => "program_title"
  end
end
