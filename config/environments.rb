# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'sequel'
require './app/lib/secure_db'

module Coinbase
  # Configureation for the API
  class Api < Roda
    plugin :environments

    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      # load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment:,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      # Make the environment variables accessible to other classes
      def self.config = Figaro.env

      # Connect and make the database accessible to other classes
      db_url = ENV.delete('DATABASE_URL')
      DB = Sequel.connect("#{db_url}?encoding=utf8")
      def self.DB = DB # rubocop:disable Naming/MethodName

      # Logger setup
      LOGGER = Logger.new($stderr)
      def self.logger = LOGGER

      # Load crypto keys
      SecureDB.setup(ENV.delete('DB_KEY'))
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock
    configure :development, :test do
      require 'pry'
      logger.level = Logger::ERROR
    end
  end
end
