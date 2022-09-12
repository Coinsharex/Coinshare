# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:loans) do
      # primary_key :id
      uuid        :id, primary_key: true
      # TEMPORARY
      foreign_key :lender_id, :accounts

      Integer     :amount, null: false
      String      :identifier, null: false, unique: true
      String      :comment
      Float       :interest_rate, null: false
      Integer     :duration, null: false
      Float       :penalty_fee, null: false
      TrueClass   :anonymous, default: false

      # ...

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
