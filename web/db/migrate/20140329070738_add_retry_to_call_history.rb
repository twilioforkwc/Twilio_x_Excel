class AddRetryToCallHistory < ActiveRecord::Migration
  def change
    add_column :call_histories, :retry, :integer, :default => 3
    add_column :call_histories, :counter, :integer, :default => 0
    add_column :call_histories, :ok_at, :string, :default => ""
  end
end
