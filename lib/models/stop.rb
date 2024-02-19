require_relative 'application_record.rb'

class Stop < ApplicationRecord
  has_many :stop_times
  has_many :trips, through: :stop_times
end
