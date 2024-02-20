# frozen_string_literal: true
require_relative 'application_record'

class Repeat < ApplicationRecord
  has_many :trips

  def days
    [
      (:monday if monday?),
      (:tuesday if tuesday?),
      (:wednesday if wednesday?),
      (:thursday if thursday?),
      (:friday if friday?),
      (:saturday if saturday?),
      (:sunday if sunday?)
    ].compact
  end
end
