class CreateUserApps < ActiveRecord::Migration
  def change
    create_table :user_apps do |t|
      t.string :auth_token
      t.string :app_sid
      t.string :token

      t.timestamps
    end
  end
end
