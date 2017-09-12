# frozen_string_literal: true

class ResourceValidator < ActiveModel::Validator
  def validate(record)
    class_name = record.name.split(/[^a-zA-Z0-9]/)[0]
    begin
      Object.const_get class_name
    rescue
      record.errors[:base] << 'Resource needs to exist'
    end
  end
end

class Channel < ActiveRecord::Base
  belongs_to :user
  validates_with ResourceValidator
  validates :name,
            presence: true,
            format: {
              with: /([A-Z])\w+(?=::create$|#update\(\d+\)$|#destroy\(\d+\)$)/
            }

  def self.listen_for_event(timeout, string)
    # connection = connection_class.connection
    connection.execute "LISTEN \"#{string}\""
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
    connection.execute "UNLISTEN \"#{string}\""
  end
end
