# frozen_string_literal: true

require 'json'
require 'sequel'

module Coinbase
  # Models a donation
  class Donation < Sequel::Model
    # many_to_one :donor, class: Coinbase::Account

    ## THIS IS TEMPORARY
    many_to_one :request
    # plugin :association_dependencies,

    plugin :timestamps

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'donation',
            attributes: {
              id:,
              amount:,
              identifier:
              # ...
            }
          }
        }, options
      )
    end
  end
end
