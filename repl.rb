require_relative 'lib/db_connection'
require_relative 'lib/models'
require_relative 'lib/segments'
require_relative 'lib/headway'

DBConnection.connect 'db.sqlite3'
