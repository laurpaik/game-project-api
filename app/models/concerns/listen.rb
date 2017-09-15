#
module Listen
  extend ActiveSupport::Concern

  module ClassMethods
    def listen_for_event(string)
      # connection = connection_class.connection
      connection.execute "LISTEN \"#{string}\""
    end

    def wait_and_unlisten(timeout)
      timed_out = false
      until timed_out
        timed_out = !connection.raw_connection
                               .wait_for_notify(timeout) do |event, pid, data|
          yield event, data, pid
        end
      end
    ensure
      connection.execute "UNLISTEN *"
    end
  end
end
