# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2020_03_20_015438) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "timescaledb"

  create_table "applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "name", null: false
    t.uuid "platform_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform_id", "name"], name: "index_applications_on_platform_id_and_name", unique: true
  end

  create_table "failures", id: false, force: :cascade do |t|
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "type", null: false
    t.text "text", null: false
    t.string "hostname", null: false
    t.jsonb "stacktrace", null: false
    t.uuid "trace_id", null: false
    t.uuid "platform_id", null: false
    t.uuid "application_id", null: false
    t.datetime "stop", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_failures_on_application_id"
    t.index ["hostname"], name: "index_failures_on_hostname"
    t.index ["id"], name: "index_failures_on_id"
    t.index ["platform_id"], name: "index_failures_on_platform_id"
    t.index ["stop"], name: "index_failures_on_stop", order: :desc
    t.index ["trace_id"], name: "index_failures_on_trace_id"
    t.index ["type"], name: "index_failures_on_type"
  end

  create_table "platforms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "name", null: false
    t.interval "retention_period", default: "P14D"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_platforms_on_name", unique: true
  end

  create_table "spans", id: false, force: :cascade do |t|
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "name", null: false
    t.datetime "start", precision: nil, null: false
    t.datetime "stop", precision: nil, null: false
    t.jsonb "meta"
    t.uuid "trace_id", null: false
    t.uuid "platform_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_spans_on_id"
    t.index ["name"], name: "index_spans_on_name"
    t.index ["start"], name: "index_spans_on_start"
    t.index ["stop"], name: "index_spans_on_stop", order: :desc
    t.index ["trace_id"], name: "index_spans_on_trace_id"
  end

  create_table "traces", id: false, force: :cascade do |t|
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "name", null: false
    t.string "hostname", null: false
    t.datetime "start", precision: nil, null: false
    t.datetime "stop", precision: nil, null: false
    t.boolean "store", default: false, null: false
    t.jsonb "meta"
    t.uuid "application_id", null: false
    t.uuid "activity_id", null: false
    t.uuid "platform_id", null: false
    t.uuid "origin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "((meta ->> 'method'::text))", name: "index_traces_meta_method"
    t.index "((stop - start))", name: "index_traces_duration"
    t.index ["activity_id"], name: "index_traces_on_activity_id"
    t.index ["application_id"], name: "index_traces_on_application_id"
    t.index ["hostname"], name: "index_traces_on_hostname"
    t.index ["id"], name: "index_traces_on_id"
    t.index ["meta"], name: "index_traces_on_meta", using: :gin
    t.index ["name"], name: "index_traces_on_name"
    t.index ["origin_id"], name: "index_traces_on_origin_id"
    t.index ["platform_id"], name: "index_traces_on_platform_id"
    t.index ["stop"], name: "index_traces_on_stop", order: :desc
  end
end
