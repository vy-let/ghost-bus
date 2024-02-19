# frozen_string_literal: true
require 'active_record'

class DBConnection
  def self.connect file
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: file
    )
  end
end
