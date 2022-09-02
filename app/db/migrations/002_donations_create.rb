# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:donations) do
      primary_key :id
      # TEMPORARY
      foreign_key :request_id, table: :requests

      String      :amount, null: false
      String      :identifier, null: false, unique: true
      # ...

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
