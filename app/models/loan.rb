# frozen_string_literal: true

require 'json'
require 'sequel'

module Coinbase
  # Models a loan
  class Loan < Sequel::Model
    many_to_one :lender, class: :'Coinbase::Account'

    many_to_many :requests,
                 class: :'Coinbase::Request',
                 join_table: :requests_loans,
                 left_key: :loan_id, right_key: :request_id

    plugin :association_dependencies,
           requests: :nullify

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :amount, :identifier, :comment, :interest_rate, :duration, :penalty_fee,
                        :anonymous

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'donation',
            attributes: {
              id:,
              amount:,
              identifier:,
              comment:,
              interest_rate:,
              duration:,
              penalty_fee:,
              anonymous:
              # ...
            }
          }
        }, options
      )
    end
  end
end
