class Review < ApplicationRecord
  # TODO: Add that it has many reviews
  validates :brand_id, uniqueness: true
  # TODO Add that lender id and review id need to be unique

end
