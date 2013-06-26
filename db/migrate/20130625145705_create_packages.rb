class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.references :batch
      t.references :status
      t.string :sip_path
      t.string :aip_identifier
      t.string :dip_identifier
      t.boolean :oral_history
      t.boolean :dark_archive
      t.boolean :approved

      t.timestamps
    end
    add_index :packages, :batch_id
    add_index :packages, :status_id
  end
end
