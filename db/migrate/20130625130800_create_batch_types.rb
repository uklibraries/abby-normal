class CreateBatchTypes < ActiveRecord::Migration
  def change
    create_table :batch_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
