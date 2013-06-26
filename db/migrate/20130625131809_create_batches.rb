class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.references :batch_type
      t.references :server
      t.string :name
      t.boolean :oral_history
      t.boolean :dark_archive

      t.timestamps
    end
    add_index :batches, :batch_type_id
    add_index :batches, :server_id
  end
end
