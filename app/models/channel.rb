# frozen_string_literal: true

class Channel < ActiveRecord::Base
  belongs_to :user
  validates :name,
            presence: true,
            format: {
              with: /([A-Z])\w+(?=::create$|#update\(\d+\)$|#destroy\(\d+\)$)/
            }

  # def channel_name
  #   self[:name]
  # end

  # FIXME: this would parse the string in each Channel instance for the model name needed, but it's in the wrong file
  # def connection_class # think of a better name
  #   constantize(channel_name.split(/[^a-zA-Z0-9]/)[0])
  # end

  def self.listen_for_event(timeout)
    # connection = connection_class.connection
    Game.connection.execute "LISTEN \"Game::create\""
    # TODO: figure out where things need to go so I don't need to hardcode
    # TODO: need something to take each Channel name as well as parse it to get the class name we're connecting on
    # TODO: get it working on one instance before worrying about looping through
    timed_out = false
    until timed_out
      timed_out = !connection.raw_connection
                             .wait_for_notify(timeout) do |event, pid, data|
        yield event, data, pid
      end
    end
  ensure
    Game.connection.execute "UNLISTEN \"Game::create\""
  end
end
