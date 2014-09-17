class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	protected
	def authorize
		unless session[:user] and User.find_by(id: session[:user][:id])
			redirect_to login_url, notice: "Please login"
		end
	end

	def current_user
		session[:user]
	end
	
	def ssl_configured?
		!Rails.env.development?
	end

	def set_headers
    #response.headers['X-XSS-Protection'] = "0"
    response.headers.except! 'X-XSS-Protection'
  end

	def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
