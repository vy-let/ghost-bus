require_relative './application_record.rb'

class Agency < ApplicationRecord
  has_many :routes
end
