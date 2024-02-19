require_relative 'lib/db_connection'
require_relative 'lib/models'
require_relative 'lib/segments'

DBConnection.connect 'db.sqlite3'
