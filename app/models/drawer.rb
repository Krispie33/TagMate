class Drawer < ApplicationRecord
  belongs_to :profile
  has_many :clothing_items, dependent: :nullify

  validates :signature, presence: true
end
