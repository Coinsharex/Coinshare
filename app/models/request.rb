# frozen_string_literal: true

require 'json'
require 'sequel'

module Coinbase
  # Models a secret request
  class Request < Sequel::Model
    many_to_one :requestor, class: :'Coinbase::Account'

    many_to_many :donations,
                 class: :'Coinbase::Donation',
                 join_table: :requests_donations,
                 left_key: :request_id, right_key: :donation_id

    plugin :association_dependencies,
           donations: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :title, :description, :location, :amount, :active, :category, :picture

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
              category:,
              amount:,
              picture:,
              active:
            }
          }
        }, options
      )
    end
  end
end
