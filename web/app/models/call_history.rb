class CallHistory < ActiveRecord::Base
	include TwilioUtils
	belongs_to :user_app

	before_save :parse_phone_number
	after_save :phone_call, if: Proc.new {|obj| obj.status == Settings.status_init}

	scope :cancel, lambda { |user_app_id| where('user_app_id = ? and (status = ? or status = ?)', user_app_id, Settings.status_init, Settings.status_start) }
end
