class RenameAppSidToAccountSidOnUserApp < ActiveRecord::Migration
  def change
		rename_column :user_apps, :app_sid, :account_sid
  end
end
