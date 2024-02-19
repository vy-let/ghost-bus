require_relative 'application_record.rb'

class Trip < ApplicationRecord
  belongs_to :route
  belongs_to :shape
  belongs_to :block
  has_many :stop_times, ->{ ordered }
  has_many :stops, through: :stop_times

  # the standard is intentionally vague on the meaning of directions 0 and 1.
  # these labels are arbitrary, and in systems where "inbound" and "outbound"
  # are actually used, they're as likely as not to be incorrect.
  scope :outbound, ->{ where direction_id: 0 }
  scope :inbound, ->{ where direction_id: 1 }
  scope :in_direction, ->(dir) { where direction_id: dir }
end
