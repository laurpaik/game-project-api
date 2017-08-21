# frozen_string_literal: true

class Channel < ActiveRecord::Base
  include Notify
  notify_on_update
  notify_on_create
  notify_before_destroy

  belongs_to :user
  validates :name, presence: true
end
