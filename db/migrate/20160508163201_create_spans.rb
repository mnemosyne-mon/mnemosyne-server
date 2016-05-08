class CreateSpans < ActiveRecord::Migration
  def change
    create_table :spans, id: :uuid do |t|
      t.uuid :trace_id
      t.string :name
      t.bigint :start
      t.bigint :stop
      t.jsonb :meta

      t.timestamps null: false
    end
  end
end
