class TwilioController < ApplicationController
  skip_before_filter :verify_authenticity_token
	before_filter :validate_request, :only => [:ivr, :result, :status, :fallback]
	before_action :set_history, :only => [:ivr, :result, :status, :fallback]
	before_action :set_history_params, :only => [:call]
	before_filter :allow_iframe
	before_filter :set_headers

	def stop
		user_app = UserApp.where(:token => params[:token].strip).first
		@client = Twilio::REST::Client.new user_app.account_sid, user_app.auth_token
		@client.account.calls.list.each do |call|
			@call = @client.account.calls.get(call.sid)
			@call.update(:status => "completed")
		end
		calls = UserApp.cancel(user_app.id)
		calls.each do |history|
			history.status = Settings.status_cancel
		end
		render :layout => false, :text => "OK"
	end

  def call
		user_app = UserApp.where(:token => params[:token].strip).first
		call_history = CallHistory.new(set_history_params)

		#Excel
		call_history.from = call_history.from.gsub(/[^0-9]/, '')

		call_history.status = Settings.status_init
		call_history.user_app_id = user_app.id
		call_history.save
		render :layout => false, :text => call_history.call_sid
  end

	def get_status
		history = CallHistory.where(:call_sid => params[:call_sid]).first
		status = history.call_status ? history.call_status : ""
		logger.debug status
		render :layout => false, :text => {:status => history.call_status, :ivr_result => history.ivr_result}.to_json
	end

	def ivr
		xml = ivr_message(@history, "")
    render :layout => false, :xml => xml
	end

  def result
		@history.ivr_result = params[:Digits]
		@history.status = Settings.status_ivr_ok
		@history.save
		if params[:Digits].to_s == @history.ok_at
    	xml = Twilio::TwiML::Response.new do |r|
				r.Say @history.message, :language => 'ja-JP'
				r.Hangup
			end.text
		else
			xml = ivr_message(@history, "入力された番号に誤りがあります。")
		end
		logger.info(xml)
    render :layout => false, :xml => xml
  end

  def status
		@history.duration = params[:CallDuration].to_i
		@history.call_status = params[:CallStatus]
		if @history.status == Settings.status_ivr_ok
			@history.status = Settings.status_end
		else
			if @history.counter < @history.retry
				#retry
				@history.status = Settings.status_init
			else
				@history.status = Settings.status_end
			end
		end
		@history.save
    xml = Twilio::TwiML::Response.new do |r|
			r.Hangup
		end
  end

  def fallback
		if @history.counter < @history.retry
			#retry
			@history.status = Settings.status_init
		else
			@history.status = Settings.status_end
		end
		@history.call_status = params[:CallStatus]
		@history.save
    xml = Twilio::TwiML::Response.new do |r|
			r.Hangup
		end
  end

	private
		def set_history
			@history = CallHistory.find(params[:call_history_id])
		end

		def set_history_params
      params.require(:call_history).permit(:phone_number, :body, :retry, :ok_at, :message, :from)
		end

		def ivr_message(history, message)
    	xml = Twilio::TwiML::Response.new do |r|
				r.Gather :numDigits => 1, :action => "/twilio/result/#{params[:call_history_id]}" do |g|
					g.Say "#{message}#{history.body}", :language => "ja-JP", :loop => 3
				end
    	end.text
		end
		def phone_call(to)

		end

		def validate_request
			history = CallHistory.find_by(id: params[:call_history_id])
			user_app = UserApp.find_by(id: history.user_app.id)
			validator = Twilio::Util::RequestValidator.new user_app.auth_token
			validator.validate(request.url, params.except(:action, :controller), request.headers['X-Twilio-Signature'])
		end
end
