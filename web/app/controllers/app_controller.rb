class AppController < ApplicationController
	before_filter :set_headers
	before_filter :allow_iframe
  def index
		@user_app = UserApp.new
  end
end
