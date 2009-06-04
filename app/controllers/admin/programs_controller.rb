class Admin::ProgramsController < ApplicationController
  before_filter :authenticate

  verify :only => [ 'destroy', 'edit', 'show' ],
  :params => :id,
  :add_flash => { :notice => 'Missing Program ID.' },
  :redirect_to => { :action => 'list' }

  verify :only => [ 'create' ],	:params => [:program],
  :method => 'post',
  :add_flash => { :notice => 'Please specify a program.' },
  :redirect_to => { :action => 'new' }

  verify :only => [ 'modify' ],	:params => [:program],
  :method => 'post',
  :add_flash => { :notice => 'Please specify a program.' },
  :redirect_to => { :action => 'edit' }

  def index
     list
     render :action => 'list'
  end

  def list
     @programs = Program.paginate(:page => params[:page] || 1,
     :per_page => 30,
     :order => "program_number ASC"
     )
  end

  def show
     @program = Program.find(params[:id])
  end

  def edit
     @program = Program.find(params[:id])
     investigators
  end

  def update

     redirect_to :action => 'list' and return if params[:commit] == 'Cancel'

     @program = Program.find(params[:id])

     if @program.update_attributes(params[:program])

        InvestigatorProgram.delete_all "program_id = #{@program.id}"

        if params[:investigators]
           params[:investigators].each do |investigator_id|
              @program.investigator_programs.create(
              :investigator_id => investigator_id,
              :program_id => @program,
              :program_appointment => 'member',
              :start_date => Time.now
              )
           end
        end

        flash[:notice] = @program.program_title + " successfully modified."
        redirect_to :action => "show", :id => @program
     else
        @program = Program.new(params[:program])
        investigators
        render :action => "edit"
     end
  end

  def new
     @program = Program.new(params[:program])
     investigators
  end

  def create
     redirect_to :action => 'list' and return if params[:commit] == 'Cancel'

     @program = Program.new(params[:program])
     @program.start_date = Time.now

     # TODO: Deal with program_number
     @program.program_number = 37

     if @program.save

        if params[:investigators]
           params[:investigators].each do |investigator_id|
              @program.investigator_programs.create(
              :investigator_id => investigator_id,
              :program_id => @program,
              :program_appointment => 'member',
              :start_date => Time.now
              )
           end
        end

        flash[:notice] = @program.program_title + " successfully created."
        redirect_to :action => "show", :id => @program
     else
        render :action => "new"
     end
  end


  def destroy
     program = Program.find(params[:id])
     name = program.program_title

     if program.destroy
        flash[:notice] = name + " was successfully removed."
     else
        flash[:error] = 'Failed to remove ' + name
     end

     redirect_to :action => 'list'
  end

  private

  def investigators
     @investigators = Investigator.find :all,
     :select => 'id, username, first_name, last_name, middle_name',
     :order => "last_name ASC"
  end
  
end
