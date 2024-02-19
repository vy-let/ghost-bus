require_relative 'application_record.rb'

class Block < ApplicationRecord
  has_many :trips
end
