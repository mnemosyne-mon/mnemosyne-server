class AddIndiciesToSpans < ActiveRecord::Migration[5.0]
  def change
    add_index :spans, :name
    add_index :spans, :trace_id

    add_index :spans, :start,
      name: 'index_spans_on_start_asc',
      order: {start: :asc},
      using: :btree

    add_index :spans, :start,
      name: 'index_spans_on_start_desc',
      order: {start: :desc},
      using: :btree
  end
end
