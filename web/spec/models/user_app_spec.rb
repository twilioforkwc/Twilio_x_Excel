require 'spec_helper'

describe UserApp do
	it "has a valid factory" do
		expect(build(:user_app)).to be_valid
	end

	it "fails with wrong accound_sid" do
		message = ""
		begin
			create(:user_app, account_sid: "wrong_sid")
		rescue => e
			message = e.message
		end
		expect(message).to eq "バリデーションに失敗しました。 アカウント情報が不正です"
	end

	it "fails with wrong auth_token" do
		message = ""
		begin
			create(:user_app, auth_token: "wrong_token")
		rescue => e
			message = e.message
		end
		expect(message).to eq "バリデーションに失敗しました。 アカウント情報が不正です"
	end

	it "fails with wrong account_sid and auth_token" do
		message = ""
		begin
			create(:user_app, account_sid: "wrong_sid", auth_token: "wrong_token")
		rescue => e
			message = e.message
		end
		expect(message).to eq "バリデーションに失敗しました。 アカウント情報が不正です"
	end
end
