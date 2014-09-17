class CreateCallHistories < ActiveRecord::Migration
  def change
    create_table :call_histories do |t|
      t.string :phone_number
      t.integer :status
      t.text :body
      t.string :ivr_result
      t.integer :user_app_id
      t.integer :duration
      t.string :call_sid

      t.timestamps
    end
  end
end
