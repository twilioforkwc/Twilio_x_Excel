class UserAppsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :set_user_app, only: [:show, :edit, :update, :destroy, :token, :appinfo, :phone]
	before_filter :authorize, except: [:token, :phone, :create, :appinfo]
	before_filter :set_headers
	before_filter :allow_iframe

	def index
		@user_apps = UserApp.all.page(params[:page]).per(20).order("id DESC")
	end

	def new
		@user_app = UserApp.new
	end

  # GET /user_apps/1
  # GET /user_apps/1.json
  #def show
  #end

	def token
		render :layout => false
	end

	def phone
		#logger.debug(@user_app.inspect)
		if request.xhr?
			if @user_app
				@call_history = CallHistory.new
				@account = @user_app.auth_app
				if @account.nil?
					render layout: false, text: "", status: 500
				else
					render layout: false
				end
			else
				render layout: false, text: "", status: 500
			end
		end
	end

	def appinfo
		account = @user_app.auth_app
		#logger.debug account.inspect
	 	render :layout => false, :text => account.to_json
	end

  # POST /user_apps
  # POST /user_apps.json
  def create
		@user_app = UserApp.find_or_create_by(user_app_params)
		if @user_app.id
			redirect_to "#{Settings.protocol}://#{Settings.service_host}/my_app/#{@user_app.token}"
		else
			@user_app.destroy!
			render :text => "アカウント情報に誤りがあります", :status => 500
   end
  end

  # PATCH/PUT /user_apps/1
  # PATCH/PUT /user_apps/1.json
  #def update
  #  respond_to do |format|
  #    if @user_app.update(user_app_params)
  #      format.html { redirect_to @user_app, notice: 'User app was successfully updated.' }
  #      format.json { head :no_content }
  #    else
  #      format.html { render action: 'edit' }
  #      format.json { render json: @user_app.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_app
      @user_app = UserApp.where(:token => params[:pin].strip).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_app_params
      params.require(:user_app).permit(:auth_token, :account_sid)
    end
end
