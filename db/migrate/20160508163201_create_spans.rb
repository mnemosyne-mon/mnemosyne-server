class CreateSpans < ActiveRecord::Migration[5.0]
  def change
    create_table :spans, id: :uuid do |t|
      t.uuid :trace_id, null: false
      t.string :name, null: false
      t.bigint :start, null: false
      t.bigint :stop, null: false
      t.jsonb :meta

      t.timestamps null: false
    end
  end
end
