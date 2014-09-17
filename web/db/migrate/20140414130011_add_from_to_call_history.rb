class AddFromToCallHistory < ActiveRecord::Migration
  def change
    add_column :call_histories, :from, :string
  end
end
