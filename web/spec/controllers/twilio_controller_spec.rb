require 'spec_helper'

describe TwilioController do

  describe "GET 'call'" do
    it "returns http success" do
      get 'call'
      response.should be_success
    end
  end

  describe "GET 'result'" do
    it "returns http success" do
      get 'result'
      response.should be_success
    end
  end

  describe "GET 'status'" do
    it "returns http success" do
      get 'status'
      response.should be_success
    end
  end

  describe "GET 'fallback'" do
    it "returns http success" do
      get 'fallback'
      response.should be_success
    end
  end

end
