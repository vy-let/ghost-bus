require_relative './application_record.rb'

class Route < ApplicationRecord
  # Stop AR trying to misinterpret the 'type' column
  self.inheritance_column = :_type_disabled

  belongs_to :agency
  has_many :trips

  # per spec, this *should* always be [0, 1].
  def directions
    @directions ||=
      trips
        .select(:direction_id).distinct
        .pluck(:direction_id)
        .sort
  end
end
