# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:requests_donations) do
      primary_key %i[request_id donation_id]
      foreign_key :request_id, :requests
      foreign_key :donation_id, :donations

      index %i[request_id donation_id]
    end
  end
end
