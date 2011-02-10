class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user
  
  private
    def current_user_session
      #logger.debug "ApplicationController::current_user_session"

			if @current_user_session
				if params[:user_session]

					if @current_user_session.login == params[:user_session][:login]
						#logger.debug "LOGINS IGUAIS"
						return @current_user_session
					else
						#logger.debug "LOGINS DIFERENTES"
						@current_user_session.destroy
						@current_user_session = UserSession.new(params[:user_session])
						return @current_user_session
					end

				end
			end
			
			#return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      #logger.debug "ApplicationController::current_user"
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def require_user
      #logger.debug "ApplicationController::require_user"
      unless current_user
        store_location
        flash[:notice] = t(:app_controller_require)
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      #logger.debug "ApplicationController::require_no_user"
      if current_user
        store_location
        flash[:notice] = t(:app_controller_require_no)
        redirect_to users_mysolar_url #account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.fullpath
    end

 #definir o idioma
  

  before_filter :set_locale
  def set_locale
    if params[:locale] ==  nil
      I18n.locale = params[:locale] || I18n.default_locale
    else
     I18n.locale = params[:locale]
    end 
  end

  def default_url_options(options={})
    {:locale => I18n.locale}
  end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end        
end

