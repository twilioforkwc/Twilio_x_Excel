json.array!(@user_apps) do |user_app|
  json.extract! user_app, :id, :auth_token, :app_sid, :token
  json.url user_app_url(user_app, format: :json)
end
