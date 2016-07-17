require "decision_tree_lib.rb"
include DecisionTreeLib

class DecisionTreesController < ApplicationController

	 skip_before_filter :verify_authenticity_token, only: [:escalate]

	def index
		@trees = current_user.decision_trees
	end

	def escalate
		dt = DecisionTree.find_by_append_url(params[:token])
		if(dt)
			decision = DecisionTreeLib::predict(dt.tree, params[:test])
			render plain: decision
		else
			render plain: "0"
		end
	end

	def list_priorities
		dt = DecisionTree.find(params[:id])
		@prio = dt.customer_priority
	end
end
