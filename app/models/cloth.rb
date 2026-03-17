class Cloth < ApplicationRecord
  belongs_to :drawer
  belongs_to :user

  has_one_attached :tag_image
  has_one_attached :item_image
end



# it equals the scan model
