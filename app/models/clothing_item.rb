class ClothingItem < ApplicationRecord
  belongs_to :drawer
  belongs_to :user

  has_one_attached :tag_image
  has_one_attached :item_image

  validates :tag_image, presence: true
  validates :item_image, presence: true
end
