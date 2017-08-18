#
module Listen
  extend ActiveSupport::Concern

  # included do
  #   after_update :notify_update
  # end

  private

  def on_update_listen_channel
    "#{self.class}#update(#{id})" # this is the channel! this is the string we need??
  end

  def on_create_listen_channel
    "#{self.class}::create"
  end

  public

  def listen_for_update(timeout)
    connection = self.class.connection
    # register the current connection/session as a listener
    # notify_update won't work without this step
    connection.execute "LISTEN \"#{on_update_listen_channel}\""
    timed_out = false
    until timed_out
      timed_out = !connection.raw_connection.wait_for_notify(timeout) do |event, pid, data|
        # until the connection times out, call the event block? do whatever action we need with the event, pid, or data?
        # in the controller case, queue.push data
        yield event, data, pid
      end
    end
  ensure
    # kind of like `finally` --> ensure that eventually we unlisten
    connection.execute "UNLISTEN \"#{on_update_listen_channel}\""
  end

  #
  module ClassMethods
    def listen_for_create
      # is it just comments we're listening for? or do we need to define some other thing?
      # LISTEN \"#{something here? on_create_listen_notify_channel maybe?}\"
      connection.execute "LISTEN \"#{on_create_listen_channel}\""
      loop do
        connection.raw_connection.wait_for_notify do |event, pid, data|
          yield data
        end
      end
    ensure
      connection.execute "UNLISTEN \"#{on_create_listen_channel}\""
    end
  end
end
