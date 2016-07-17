class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :name
      t.string :attachment
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
