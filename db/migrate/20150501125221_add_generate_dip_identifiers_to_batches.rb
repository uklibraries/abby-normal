class AddGenerateDipIdentifiersToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :generate_dip_identifiers, :boolean
    add_column :packages, :generate_dip_identifiers, :boolean
  end
end
