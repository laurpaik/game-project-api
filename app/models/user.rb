#
class User < ActiveRecord::Base
  include Authentication
  has_many :games
  has_many :channels
end
