require "decision_tree_lib.rb"
include DecisionTreeLib
class Upload < ActiveRecord::Base
	mount_uploader :attachment, AttachmentUploader # Tells rails to use this uploader for this model.
   	validates :name, presence: true # Make sure the owner's name is present.
   	belongs_to :user
   	has_one :decision_tree, :dependent => :delete

   	def process_upload
   		DecisionTreeLib::decision_tree("", attachment.current_path, "final_escalation_level", "customer_name", id, user_id)
   	end
end
