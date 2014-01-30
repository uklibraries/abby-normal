class AddFixityFieldsToPackage < ActiveRecord::Migration
  def change
    add_column :packages, :local_aip_fixed, :boolean
    add_column :packages, :local_dip_fixed, :boolean
    add_column :packages, :remote_test_dip_fixed, :boolean
    add_column :packages, :remote_dip_fixed, :boolean
    add_column :packages, :remote_aip_fixed, :boolean
  end
end
