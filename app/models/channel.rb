# frozen_string_literal: true

class Channel < ActiveRecord::Base
  belongs_to :user
  validates :name,
            presence: true,
            format: {
              with: /([A-Z])\w+#(?=create$|update\(\d+\)$|destroy\(\d+\)$)/
            }
end
