class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :drawer
  has_many :messages, dependent: :destroy
end
