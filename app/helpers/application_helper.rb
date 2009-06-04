# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def render_if_exists(partial)
    if File.exists?(File.expand_path(RAILS_ROOT + '/app/views/' + params[:controller] + '/' + "_#{partial}.html.erb"))
      render :partial => partial 
  	end
  end
  
  def year_range_display
    if session[:years].starting == session[:years].ending
      " (#{session[:years].starting})"
    elsif !session[:years].show_all?
      " (#{session[:years].starting} - #{session[:years].ending})"
    else
      ""
    end
  end
end
