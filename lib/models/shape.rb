require_relative 'application_record.rb'

class Shape < ApplicationRecord
  has_many :path_points
  has_many :trips
end
