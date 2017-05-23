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

ActiveRecord::Schema.define(version: 20170523163542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "activities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "platform_id", null: false
  end

  create_table "applications", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.uuid "platform_id", null: false
    t.index ["platform_id", "name"], name: "index_applications_on_platform_id_and_name", unique: true
  end

  create_table "platforms", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_platforms_on_name", unique: true
  end

  create_table "spans", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "trace_id", null: false
    t.string "name", null: false
    t.bigint "start", null: false
    t.bigint "stop", null: false
    t.jsonb "meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_spans_on_name"
    t.index ["start"], name: "index_spans_on_start"
    t.index ["trace_id"], name: "index_spans_on_trace_id"
  end

  create_table "traces", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "application_id", null: false
    t.uuid "activity_id", null: false
    t.uuid "origin_id"
    t.string "name", null: false
    t.bigint "start", null: false
    t.bigint "stop", null: false
    t.jsonb "meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "platform_id", null: false
    t.index ["name", "start"], name: "index_traces_on_name_start_desc", order: { start: :desc }
    t.index ["name"], name: "index_traces_on_name"
    t.index ["origin_id", "start"], name: "index_traces_on_origin_start_desc", order: { start: :desc }, where: "(origin_id IS NULL)"
    t.index ["origin_id"], name: "index_traces_on_origin_id"
    t.index ["platform_id", "created_at"], name: "index_traces_on_platform_id_and_created_at"
    t.index ["platform_id"], name: "index_traces_on_platform_id"
    t.index ["start"], name: "index_traces_on_start_desc", order: { start: :desc }
  end

end
