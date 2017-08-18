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

  def notify_update
    root = self.class.to_s.downcase
    # save the changes in a hash with the root as the key
    payload = { root => changes }.to_json
    # tell postgres to run `notify`
    # sends notification event to that channel defined earlier with the payload
    self.class.connection.execute(
      "NOTIFY \"#{on_update_notify_channel}\", '#{payload}'"
    )
  end

  def notify_create
    connection.execute(
      # notify the channel with the changes as the payload message
      "NOTIFY \"#{on_create_notify_channel}\", '#{changes}'"
    )
  end

  #
  module ClassMethods
    def notify_on_update
      # after each update, run notify update --> this is what we call in model
      after_update :notify_update
    end

    def notify_on_create
      after_create :notify_create
    end

    # def notify_before_destroy
    #   before_action :destroy, :notify_destroy
    # end
  end
end
