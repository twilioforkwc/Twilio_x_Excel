class WelcomeController < ApplicationController
	before_filter :set_headers
	before_filter :allow_iframe
  def index
  end
end
