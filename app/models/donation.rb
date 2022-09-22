# frozen_string_literal: true

require 'json'
require 'sequel'

module Coinbase
  # Models a loan
  class Donation < Sequel::Model
    many_to_one :donor, class: :'Coinbase::Account'

    many_to_many :requests,
                 class: :'Coinbase::Request',
                 join_table: :requests_donations,
                 left_key: :donation_id, right_key: :request_id

    plugin :association_dependencies,
           requests: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :amount, :identifier, :comment, :anonymous

    def to_json(options = {})
      JSON(
        {
          type: 'donation',
          attributes: {
            id:,
            amount:,
            identifier:,
            comment:,
            anonymous:
            # ...
          }
        }, options
      )
    end
  end
end
