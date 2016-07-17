class AddCustomerPrioToDecisionTree < ActiveRecord::Migration
  def change
  	add_column :decision_trees, :customer_priority, :text
  end
end
