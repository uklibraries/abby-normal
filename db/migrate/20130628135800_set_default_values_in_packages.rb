class SetDefaultValuesInPackages < ActiveRecord::Migration
  def change
    change_column_default :packages, :oral_history, 0
    change_column_default :packages, :dark_archive, 0
  end
end
