class UserApp < ActiveRecord::Base

	has_many :call_histories

	include Tokenable
	include TwilioUtils
	validates :account_sid, :presence => true
	validates :auth_token, :presence => true
	#TODO account_sidとauth_tokenの複合ユニーク制約
	
	before_save :auth_app, :on => :create
end
