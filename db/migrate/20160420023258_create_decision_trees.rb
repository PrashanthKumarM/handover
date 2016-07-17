class CreateDecisionTrees < ActiveRecord::Migration
  def change
    create_table :decision_trees do |t|
    	t.integer :user_id
    	t.integer :upload_id
    	t.text :tree
    	t.string :append_url
    end
  end
end
