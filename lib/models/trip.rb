require_relative 'application_record.rb'

class Trip < ApplicationRecord
  belongs_to :route
  belongs_to :shape
  belongs_to :block
  has_many :stop_times
  has_many :stops, through: :stop_times

  scope :outbound, ->{ where direction_id: 0 }
  scope :inbound, ->{ where direction_id: 1 }
end
