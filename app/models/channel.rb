# frozen_string_literal: true

class Channel < ActiveRecord::Base
  include ListenNotify

  notify_on_update

  validates :name, presence: true
end
