class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :package
      t.references :type
      t.references :status

      t.timestamps
    end
    add_index :tasks, :package_id
    add_index :tasks, :type_id
    add_index :tasks, :status_id
  end
end
