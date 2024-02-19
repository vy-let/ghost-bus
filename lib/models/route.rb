require_relative './application_record.rb'

class Route < ApplicationRecord
  # Stop AR trying to misinterpret the 'type' column
  self.inheritance_column = :_type_disabled

  belongs_to :agency
  has_many :trips
end
