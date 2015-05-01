class SetDefaultValuesForIdentifiersInBatches < ActiveRecord::Migration
  def change
    change_column_default :batches, :generate_dip_identifiers, 1
    change_column_default :packages, :generate_dip_identifiers, 1
  end
end
