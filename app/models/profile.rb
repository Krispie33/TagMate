class Profile < ApplicationRecord
  belongs_to :user
  has_many :machines, dependent: :destroy
  has_many :drawers, dependent: :destroy
  accepts_nested_attributes_for :machines, reject_if: :all_blank

  validates :name, presence: true
end
