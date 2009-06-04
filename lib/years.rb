class Years
  attr_accessor :starting, :ending, :years, :show_all

  def initialize(starting = nil, ending = nil)
    starting.nil? ? @starting = Time.now.year - 5 : @starting = starting
    ending.nil? ? @ending = Time.now.year : @ending = ending
    @years = (@starting..@ending).sort {|a,b| b <=> a}
    @show_all = false
  end
  
  def starting=(starting)
    @years.include?(starting.to_i) ? @starting = starting.to_i : @starting = @years.last
  end
  
  def ending=(ending)
    @years.include?(ending.to_i) ? @ending = ending.to_i : @ending = @years.first
  end
  
  def show_all?
    @show_all
  end
  
  def first
    @years.last
  end
  
  def last
    @years.first
  end
    
  def dynamic_years_start
    @years[@years.index(@ending)..@years.index(@years.last)] 
  end
  
  def dynamic_years_end
     @years[0..@years.index(@starting)]
  end
  
end

