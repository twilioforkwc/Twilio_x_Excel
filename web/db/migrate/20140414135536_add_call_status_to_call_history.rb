class AddCallStatusToCallHistory < ActiveRecord::Migration
  def change
    add_column :call_histories, :call_status, :string
  end
end
