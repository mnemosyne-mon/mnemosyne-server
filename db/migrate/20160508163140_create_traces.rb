class CreateTraces < ActiveRecord::Migration[5.0]
  def change
    create_table :traces, id: :uuid do |t|
      t.uuid :application_id, null: false
      t.uuid :transaction_id, null: false
      t.uuid :origin_id
      t.string :name, null: false
      t.bigint :start, null: false
      t.bigint :stop, null: false
      t.jsonb :meta

      t.timestamps null: false
    end
  end
end
