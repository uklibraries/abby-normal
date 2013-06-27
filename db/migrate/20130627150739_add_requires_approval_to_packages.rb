class AddRequiresApprovalToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :requires_approval, :boolean
  end
end
