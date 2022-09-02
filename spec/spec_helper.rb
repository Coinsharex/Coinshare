# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:donations].delete
  app.DB[:requests].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:donations] = YAML.safe_load File.read('app/db/seeds/donation_seeds.yml')
DATA[:requests] = YAML.safe_load File.read('app/db/seeds/request_seeds.yml')
