# frozen_string_literal: true

require 'json'
require 'sequel'

module Coinbase
  # Models a secret request
  class Request < Sequel::Model
    many_to_one :requestor, class: :'Coinbase::Account'

    many_to_many :loans,
                 class: :'Coinbase::Loan',
                 join_table: :requests_loans,
                 left_key: :request_id, right_key: :loan_id

    plugin :association_dependencies,
           loans: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :description, :location, :amount, :active

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'request',
            attributes: {
              id:,
              title:,
              description:,
              location:,
              amount:,
              active:
            }
          }
        }, options
      )
    end
  end
end
