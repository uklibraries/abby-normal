class AddOnlineToPackage < ActiveRecord::Migration
  def change
    add_column :packages, :online, :boolean, :default => 0
  end
end
