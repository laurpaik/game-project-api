# frozen_string_literal: true
# concern for notify
module Notify
  extend ActiveSupport::Concern

  private

  def on_update_notify_channel # think of a better name
    "#{self.class}#update(#{id})"
  end

  def on_create_notify_channel
    "#{self.class}::create"
  end

  def before_destroy_notify_channel
    "#{self.class}#destroy(#{id})"
  end

  def notify_update
    root = self.class.to_s.downcase
    payload = { root => changes }.to_json
    self.class.connection.execute(
      "NOTIFY \"#{on_update_notify_channel}\", '#{payload}'"
    )
  end

  def notify_create
    self.class.connection.execute(
      "NOTIFY \"#{on_create_notify_channel}\", '#{changes}'"
    )
  end

  def notify_destroy
    self.class.connection.execute(
      "NOTIFY \"#{before_destroy_notify_channel}\", 'Destroying #{self.class}(#{id})'"
    )
  end

  module ClassMethods
    def notify_on_update
      after_update :notify_update
    end

    def notify_on_create
      after_create :notify_create
    end

    def notify_before_destroy
      before_destroy :notify_destroy
    end
  end
end
