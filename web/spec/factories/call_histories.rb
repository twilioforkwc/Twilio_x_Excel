# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :call_history do
    phone_number "+81901112222"
    status 5
    body "MyText"
    message "MyText"
    from "+8144444444"
    ok_at "1"
    ivr_result "1"
    user_app_id 1
    duration 100
    call_sid "abcdefghijklmnopqrstuvwxyz"
  end
end
