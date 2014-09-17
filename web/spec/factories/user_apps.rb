# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_app do
    auth_token "MyString"
    account_sid "MyString"
  end
end
