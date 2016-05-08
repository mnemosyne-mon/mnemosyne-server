class CreateTraces < ActiveRecord::Migration
  def change
    create_table :traces, id: :uuid do |t|
      t.uuid :application_id
      t.uuid :transaction_id
      t.uuid :origin_id
      t.string :name
      t.bigint :start
      t.bigint :stop
      t.jsonb :meta

      t.timestamps null: false
    end
  end
end
