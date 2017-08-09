# frozen_string_literal: true

class Channel < ActiveRecord::Base
  validates :name, presence: true
end
