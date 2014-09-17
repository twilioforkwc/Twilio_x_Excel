json.array!(@call_histories) do |call_history|
  json.extract! call_history, :id, :phone_number, :status, :body, :ivr_result, :user_app_id, :duration, :call_sid
  json.url call_history_url(call_history, format: :json)
end
