require 'securerandom'

class DecisionTree < ActiveRecord::Base
	belongs_to :user
	belongs_to :upload

	before_save :create_url
	serialize :tree, Hash
	serialize :customer_priority, Hash

	private

	def create_url
		self.append_url = SecureRandom.hex
	end
end