class AddStatusToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :status_id, :integer
  end
end
