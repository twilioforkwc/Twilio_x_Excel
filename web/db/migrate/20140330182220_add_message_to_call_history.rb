class AddMessageToCallHistory < ActiveRecord::Migration
  def change
    add_column :call_histories, :message, :text
  end
end
