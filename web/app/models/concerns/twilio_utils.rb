module TwilioUtils
  extend ActiveSupport::Concern

	def auth_app
		begin
			@client = Twilio::REST::Client.new self.account_sid, self.auth_token
			@account = @client.accounts.get(self.account_sid)
			sid = @account.sid
			type = @account.type
			status = @account.status
			return_data = {}
			if self.account_sid != sid || status != 'active'
				errors[:base] << "アカウント情報が不正です"
				raise ActiveRecord::RecordInvalid.new(self)
			else
				phone_numbers = []
				phone_numbers = @client.account.incoming_phone_numbers.list.map{|number| number.phone_number}
				return_data = {sid: sid, type: @account.type, status: @account.status, friendly_name: @account.friendly_name, phone_number: phone_numbers}
			end
		rescue Exception => e
			logger.info(e.message)
			return_data = nil
			errors[:base] << "アカウント情報が不正です"
			raise ActiveRecord::RecordInvalid.new(self)
		end
		return return_data
	end

	protected
	def parse_phone_number
		self.formatted_number = self.phone_number
		self.from = self.from.gsub(/[^0-9+]/, '')
	end

	def formatted_number=(number)
		zen = ['１', '２', '３', '４', '５', '６', '７', '８', '９', '０']
		han = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
		number = "" if number.nil?
		zen.each_with_index{|z, i| number = number.to_s.gsub(z, han[i])}
		number = number.gsub(/[^0-9]/, '')
		number = number.gsub(/^0/, '81')
		number = '+' + number
		self.phone_number = number
	end


	def phone_call
		url = "#{Settings.protocol}://#{Settings.service_host}/twilio/ivr/#{self.id}"
		status = "#{Settings.protocol}://#{Settings.service_host}/twilio/status/#{self.id}"
		fallback = "#{Settings.protocol}://#{Settings.service_host}/twilio/fallback/#{self.id}"

		#logger.debug(self.from)
		#if self.from[0] != '8'
		#	from = self.from.gsub!(/^([0-9])/, "+#{$1}")
		#else
		#	from = self.from
		#end

		user_app = UserApp.find(self.user_app_id)
		@client = Twilio::REST::Client.new user_app.account_sid, user_app.auth_token
		@call = @client.account.calls.create(
  		:from => self.from,
			:method => 'POST',
  		:to => self.phone_number,
  		:url => url,
			:StatusCallback => status,
			:FallbackUrl => fallback
		)
		self.call_sid = @call.sid
		self.counter += 1
		self.status = Settings.status_start
		self.save
	end
end
