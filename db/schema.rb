# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170717153926) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"
  enable_extension "timescaledb"

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "platform_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "name", null: false
    t.uuid "platform_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform_id", "name"], name: "index_applications_on_platform_id_and_name", unique: true
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
    t.bigint "start", null: false
    t.bigint "stop", null: false
    t.jsonb "meta"
    t.uuid "trace_id", null: false
    t.uuid "platform_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_spans_on_id"
    t.index ["name"], name: "index_spans_on_name"
    t.index ["platform_id", "stop"], name: "spans_platform_id_stop_idx", order: { stop: :desc }
    t.index ["start"], name: "index_spans_on_start"
    t.index ["stop"], name: "spans_stop_idx", order: { stop: :desc }
    t.index ["trace_id"], name: "index_spans_on_trace_id"
  end

  create_table "traces", id: false, force: :cascade do |t|
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "name", null: false
    t.string "hostname", null: false
    t.bigint "start", null: false
    t.bigint "stop", null: false
    t.boolean "store", default: false, null: false
    t.jsonb "meta"
    t.uuid "application_id", null: false
    t.uuid "activity_id", null: false
    t.uuid "platform_id", null: false
    t.uuid "origin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "((meta ->> 'method'::text))", name: "idx_traces_filter_method"
    t.index ["hostname"], name: "index_traces_on_hostname"
    t.index ["id"], name: "index_traces_on_id"
    t.index ["meta"], name: "index_traces_on_meta", using: :gin
    t.index ["name"], name: "index_traces_on_name"
    t.index ["origin_id"], name: "index_traces_on_origin_id"
    t.index ["platform_id", "stop"], name: "traces_platform_id_stop_idx", order: { stop: :desc }
    t.index ["platform_id"], name: "index_traces_on_platform_id"
    t.index ["stop"], name: "index_traces_on_stop", order: { stop: :desc }
  end

end
