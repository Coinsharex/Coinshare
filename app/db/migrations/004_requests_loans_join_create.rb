# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:requests_loans) do
      primary_key %i[request_id loan_id]
      foreign_key :request_id, :requests
      foreign_key :loan_id, :loans

      index %i[request_id loan_id]
    end
  end
end
