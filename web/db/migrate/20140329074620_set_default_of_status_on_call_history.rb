class SetDefaultOfStatusOnCallHistory < ActiveRecord::Migration
  def change
		change_column :call_histories, :status, :integer, :default => 1
  end
end
