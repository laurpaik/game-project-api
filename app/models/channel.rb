# frozen_string_literal: true

class Channel < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true
end
