class SetDefaultValuesInBatches < ActiveRecord::Migration
  def change
    change_column_default :batches, :oral_history, 0
    change_column_default :batches, :dark_archive, 0
  end
end
