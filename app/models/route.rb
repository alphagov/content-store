class Route < ApplicationRecord
  belongs_to :content_item, required: false
  belongs_to :publish_intent, required: false
end
