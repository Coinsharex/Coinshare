# frozen_string_literal: true

require 'json'
require 'sequel'

module Coinbase
  # Models a RequestDonationsDetails
  class RequestDonationsDetails < Sequel::Model
    many_to_one :request, class: :'Coinbase::Request'

    plugin :association_dependencies

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :count, :amount

    def to_json(options = {})
      JSON(
        {
          type: 'request_donations_details',
          attributes: {
            count:,
            amount:
          },
          include: {
            request:
          }
        }, options
      )
    end
  end
end
