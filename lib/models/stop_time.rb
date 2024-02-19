require_relative 'application_record.rb'

class StopTime < ApplicationRecord
  belongs_to :trip
  belongs_to :stop

  scope :ordered, ->{ order seq: :asc }
end
