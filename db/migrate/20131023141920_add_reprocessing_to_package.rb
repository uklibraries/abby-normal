class AddReprocessingToPackage < ActiveRecord::Migration
  def change
    add_column :packages, :reprocessing, :boolean, :default => 0
  end
end
