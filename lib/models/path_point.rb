require_relative 'application_record.rb'

class PathPoint < ApplicationRecord
  belongs_to :shape
end
