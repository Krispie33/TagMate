class Profile < ApplicationRecord
  belongs_to :user
  has_many :machines, dependent: :destroy
  has_many :drawers, dependent: :destroy
end
