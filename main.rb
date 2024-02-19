# frozen_string_literal: true

class Main
  def self.main
    if help?
      $stderr.puts <<~HELP
        uhh. uhhhhhhhh.
      HELP
      return
    end

    require_relative 'lib/db_connection'
    DBConnection.connect db_file

    case verb
    when 'import'
      require_relative 'lib/slurp'
      Slurp.new(gtfs:).setup

    else
      $stderr.puts 'i don’t know what you want me to do. try `--help`'
    end

  rescue Exception => e
    # Silence backtrace on exceptions unless requested
    $stderr.puts e.inspect
    $stderr.puts(e.backtrace) if show_trace?
  end


  def self.help?
    ARGV.intersection(['--help', '-h']).any?
  end

  def self.verb
    ARGV.first
  end

  def self.db_file
    './db.sqlite3'
  end

  def self.gtfs
    ARGV[1]
  end

  def self.show_trace?
    ARGV.include? '--show-trace'
  end
end
