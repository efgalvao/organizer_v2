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

ActiveRecord::Schema[7.0].define(version: 2024_03_04_112634) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_reports", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.integer "initial_account_balance_cents"
    t.integer "final_account_balance_cents"
    t.integer "month_balance_cents"
    t.integer "month_income_cents"
    t.integer "month_expense_cents"
    t.integer "month_invested_cents"
    t.integer "month_dividends_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date"
    t.integer "reference"
    t.index ["account_id"], name: "index_account_reports_on_account_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.integer "balance_cents", default: 0, null: false
    t.integer "kind", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "user_id"], name: "index_accounts_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "financings", force: :cascade do |t|
    t.string "name", null: false
    t.integer "borrowed_value_cents", default: 0, null: false
    t.integer "installments", default: 0, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_financings_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "financing_id", null: false
    t.boolean "ordinary", default: true
    t.integer "parcel", default: 0
    t.integer "paid_parcels", default: 1
    t.date "payment_date"
    t.integer "amortization_cents", default: 0
    t.integer "interest_cents", default: 0
    t.integer "insurance_cents", default: 0
    t.integer "fees_cents", default: 0
    t.integer "monetary_correction_cents", default: 0
    t.integer "adjustment_cents", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["financing_id"], name: "index_payments_on_financing_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "account_report_id"
    t.bigint "category_id"
    t.integer "value_cents", default: 0, null: false
    t.integer "kind", default: 0, null: false
    t.string "title", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["account_report_id"], name: "index_transactions_on_account_report_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.string "username", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "account_reports", "accounts"
  add_foreign_key "accounts", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "financings", "users"
  add_foreign_key "payments", "financings"
  add_foreign_key "transactions", "account_reports"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "categories"
end
