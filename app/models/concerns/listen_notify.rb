#
module ListenNotify
  extend ActiveSupport::Concern

  # included do
  #   after_update :notify_update
  # end

  private

  def on_update_listen_notify_channel
    "#{self.class}#update(#{id})" # this is the channel! this is the string we need??
  end

  def on_create_listen_notify_channel
    "#{self.class}::create"
  end

  def notify_update
    # e.g. class Channel --> root = "channel"
    root = self.class.to_s.downcase
    # save the changes in a hash with the root as the key
    # I hate syntactic sugar
    payload = { root => changes }.to_json
    # tell postgres to run `notify`
    # sends a notification event to that channel defined earlier with the payload message
    self.class.connection.execute(
      "NOTIFY \"#{on_update_listen_notify_channel}\", '#{payload}'"
    )
  end

  public

  def listen_for_update(timeout)
    connection = self.class.connection
    # register the current connection/session as a listener
    # notify_update won't work without this step
    connection.execute "LISTEN \"#{on_update_listen_notify_channel}\""
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
    connection.execute "UNLISTEN \"#{on_update_listen_notify_channel}\""
  end

  #
  module ClassMethods
    def notify_on_update
      # after each update, run notify update --> this is what we call in our model
      after_update :notify_update
    end

    def notify_create
      connection.execute(
      # notify the channel with the changes as the payload message
        "NOTIFY \"#{on_create_listen_notify_channel}\", '#{changes}'"
      )
    end

    def listen_for_create
      # is it just comments we're listening for? or do we need to define some other thing?
      # LISTEN \"#{something here? on_create_listen_notify_channel maybe?}\"
      connection.execute "LISTEN comments"
      loop do
        connection.raw_connection.wait_for_notify do |event, pid, data|
          yield data
        end
      end
    ensure
      connection.execute 'UNLISTEN comments'
    end
  end
end
