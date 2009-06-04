class AbstractsController < ApplicationController
  before_filter  :get_programs
  before_filter  :get_investigators
  before_filter  :find_last_load_date
  before_filter  :initialize_years
  
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  
  verify :only => [  'member', 'show', 'program' ], :params => :id,
     :add_flash => { :notice => 'Missing Investigator ID.' },
     :redirect_to => { :action => 'list' }
 
  def index
    list
  end
  
  def list
    params[:page] = 1 if !params[:page]
    params[:page] = nil if params[:all]
    
    if session[:years].show_all?
      @title = "All Publications"
      @abstracts = Abstract.paginate(:page => params[:page])
    else
      @title = "Publications"
      @abstracts = Abstract.years(session[:years].starting, session[:years].ending).paginate(:page => params[:page])
    end
    
    if !params[:all]
      @total_found = @abstracts.total_entries
    else
      @all = true
      @total_found = @abstracts.total_entries
    end
    
    if session[:search]
      @search = session[:search]
    end
    
    if params[:print]
      render :action => 'print_view', :layout => 'print'
    else
      render :action => 'list'
    end
  end
  

  def search 
    
    if params[:search]
      session[:search] = Search.new
      session[:search].text = params[:search][:text]
      session[:search].field = params[:search][:field]
      @search = session[:search]
    elsif session[:search]
      @search = session[:search]
    else
      redirect_to :action => 'list'
      return
    end  
          
    if @search.field == 'Author'
      @abstracts = Abstract.author(@search.text)
    elsif @search.field == 'Title'
      @abstracts = Abstract.title(@search.text)      
    elsif @search.field == 'Journal'
      @abstracts = Abstract.journal(@search.text)
    elsif @search.field == 'Abstract'
      @abstracts = Abstract.abstract(@search.text)
    else
      @abstracts = Abstract.containing(@search.text)
    end
    
    params[:page] = 1 if !params[:page]
    params[:page] = nil if params[:all]
    
    if session[:years].show_all?
      @abstracts = @abstracts.paginate(:page => params[:page])
    else
      @abstracts = @abstracts.years(session[:years].starting, session[:years].ending).paginate(:page => params[:page])
    end
    
    @title = "Search for "+ @search.text + " in " + @search.field
      
    if !params[:all]
       @total_found = @abstracts.total_entries
     else
       @all = true
       @total_found = @abstracts.length
     end        
      
    if params[:print]
      render :action => 'print_view', :layout => 'print'
    else
      render :action => 'list'
    end

  end 
 
  
  def program
  
    program = Program.find(params[:id])
    
    params[:page] = 1 if !params[:page]
    
    if session[:years].show_all?
      @abstracts = Abstract.program(params[:id]).paginate(:page => params[:page])
      @total_found = @abstracts.total_entries
    else
      @abstracts = Abstract.program(params[:id]).years(session[:years].starting, session[:years].ending).paginate(:page => params[:page])
      @total_found = @abstracts.total_entries
    end
        
    @program_id = params[:id]

    @title = "#{program.program_title}"
    
    if params[:print]
      render :action => 'print_view', :layout => 'print'
    else
      render :action => 'list'
    end
  
  end
  
  
  def faculty
    @program_id = params[:id]
    
    @faculty = Investigator.find :all, 
      :order => "last_name ASC, first_name ASC",
      :include => ["current_programs"],
      :conditions => ["programs.id =:program_id",
        {:program_id => @program_id}]
    
    @title = "#{Program.find(params[:id]).program_title} faculty"
  end

 
  def member
       
    if member = Investigator.find(:first, :conditions => ["username = ?", params[:id]])
      @title = "Publications for #{member.fullname}" 
      @investigator_id = params[:id]
      
      params[:page] = 1 if !params[:page]
      
      if session[:years].show_all?
        @abstracts = Abstract.member(member.id).paginate(:page => params[:page])
      else
        @abstracts = Abstract.member(member.id).years(session[:years].starting, session[:years].ending).paginate(:page => params[:page])
      end
      
      @total_found = @abstracts.total_entries
      
      if params[:print]
        render :action => 'print_view', :layout => 'print'
      else
        render :action => 'list'
      end
      
    else
      flash[:error] = "Investigator does not exist."
      redirect_to :action => 'list'
    end
    
  end 

  def show
    @publication = Abstract.find(params[:id])
  end

  def endnote
    @publication = Abstract.find(params[:id])
    
    reference = Bio::Reference.new(
      'authors' => @publication.authors,
      'title' => @publication.title,
      'journal' => @publication.journal,
      'volume' => @publication.volume,
      'issue' => @publication.issue,
      'pages' => @publication.pages,
      'year' => @publication.year,
      'pubmed' => @publication.pubmed,
      'abstract' => @publication.abstract ? @publication.abstract : "",
      'url' => @publication.url ? @publication.url : ""
     # 'mesh' => @publication.mesh
    )
    
    @citation = reference.endnote.gsub("%","<br/>%")
  end
  
end


class Search
 attr_accessor :text, :field
end

