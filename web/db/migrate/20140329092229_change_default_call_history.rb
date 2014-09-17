class ChangeDefaultCallHistory < ActiveRecord::Migration
  def change
		change_column :call_histories, :status, :integer, :default => 0
  end
end
