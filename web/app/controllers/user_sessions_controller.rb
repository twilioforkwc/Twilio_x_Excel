class UserSessionsController < ApplicationController
  def new
		@user = User.new
  end

  def create
		@user = User.find_by(username: params[:username])
		if @user and @user.authenticate(params[:password])
			session[:user] = {username: @user.username, id: @user.id}
			redirect_to @user, notice: "Logged in"
		else
			render 'new', notice: "Login failed"
		end
  end

  def destroy
		session[:user] = nil
		redirect_to root_path, notice: "Logged out"
  end
end
