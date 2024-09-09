class Route < ApplicationRecord
  belongs_to :content_item, required: false
end
