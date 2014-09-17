require 'spec_helper'

describe CallHistory do
	it "has a valid factory" do
		expect(build(:call_history)).to be_valid
	end

	it "parses phone number before save" do
		correct_number = '+81333333333'
		expect(build(:call_history, formatted_number: "03-3333-3333").phone_number).to eq correct_number
		expect(build(:call_history, formatted_number: "０３−３３３３−３３３３").phone_number).to eq correct_number
		expect(build(:call_history, formatted_number: "0333333333").phone_number).to eq correct_number
	end

	it "cancels ongoing outbound call" do
		call_history = create(:call_history, status: Settings.status_start, user_app_id: 1000)
		ongoing = CallHistory.cancel(1000)
		expect(ongoing.length).to eq 1
	end

end
