class LoginController < ApplicationController
	before_filter :logged_in?
	
	def index
			
		if request.post?
			
			error = false

			if !params[:login][:username].empty?

				if CONFIG[:app][:admins].include?(params[:login][:username])
				  			  
				  ldap = MyLDAP.new(CONFIG[:ldap])
  
					if ldap.authenticate(params[:login][:username], params[:login][:password])
						session[:user] = Hash.new
            session[:user][:id] = params[:login][:username]
            session[:user][:name] = ldap.person_get_attribute(params[:login][:username], 'givenName')

						if params[:login][:username] != cookies[@default_cookie_name]
							cookies[CONFIG[:app][:cookie_prefix] + '_login'] = {:value => params[:login][:username], :expires => Time.now+31536000}
						end
						
					else
						flash[:error] = "Invalid password."
						error = true
					end

				else
					flash[:error] = "You are not authorized to use this application."
					error = true
				end

				if error
					@username = params[:login][:username]
				elsif session[:return_to]
					redirect_to session[:return_to]
				else
					redirect_to :controller => CONFIG[:app][:default_controller]
				end

			end
				
		
		else
		
		  if session[:user]
   		   redirect_to :controller => CONFIG[:app][:default_controller]
			elsif params[:username]
				@username = params[:username]
			elsif !cookies[CONFIG[:app][:cookie_prefix] + '_login'].blank?
				@username = cookies[CONFIG[:app][:cookie_prefix] + '_login']
			end	
			
			@notice = "You are now logged out." if params[:done]  
			  
		end
	
	end
		
	
	protected	  

    def logged_in?
      if session[:user]
        redirect_to :controller => CONFIG[:app][:default_controller]
        return false
      end
    end
    
end
