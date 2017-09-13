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
  include Listen

  belongs_to :user
  validates_with ResourceValidator
  validates :name,
            presence: true,
            format: {
              with: /([A-Z])\w+(?=::create$|#update\(\d+\)$|#destroy\(\d+\)$)/
            }
end
