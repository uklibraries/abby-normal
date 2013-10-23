class AddReprocessingToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :reprocessing, :boolean, :default => 0
  end
end
