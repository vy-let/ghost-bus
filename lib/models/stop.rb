require_relative 'application_record.rb'

class Stop < ApplicationRecord
  has_many :stop_times, ->{ ordered }
  has_many :trips, through: :stop_times

  scope :for_trip, ->(trips) { joins(:trips).where(trips: {id: trips}) }
end
