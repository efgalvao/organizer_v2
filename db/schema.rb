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

ActiveRecord::Schema[7.0].define(version: 2024_07_30_021809) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_reports", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.date "date"
    t.integer "initial_account_balance_cents", default: 0, null: false
    t.integer "final_account_balance_cents", default: 0, null: false
    t.integer "month_balance_cents", default: 0, null: false
    t.integer "month_income_cents", default: 0, null: false
    t.integer "month_expense_cents", default: 0, null: false
    t.integer "month_invested_cents", default: 0, null: false
    t.integer "month_dividends_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "dividends", force: :cascade do |t|
    t.bigint "investment_id", null: false
    t.integer "amount_cents", default: 0, null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shares"
    t.index ["investment_id"], name: "index_dividends_on_investment_id"
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

  create_table "investments", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.integer "invested_value_cents", default: 0, null: false
    t.integer "current_value_cents", default: 0, null: false
    t.boolean "released", default: false, null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shares_total", default: 0
    t.index ["account_id"], name: "index_investments_on_account_id"
  end

  create_table "negotiations", force: :cascade do |t|
    t.string "negotiable_type", null: false
    t.bigint "negotiable_id", null: false
    t.date "date"
    t.integer "amount_cents", default: 0, null: false
    t.integer "shares", default: 0, null: false
    t.integer "kind", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["negotiable_type", "negotiable_id"], name: "index_negotiations_on_negotiable"
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

  create_table "positions", force: :cascade do |t|
    t.string "positionable_type", null: false
    t.bigint "positionable_id", null: false
    t.date "date"
    t.integer "amount_cents", default: 0, null: false
    t.integer "shares", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["positionable_type", "positionable_id"], name: "index_positions_on_positionable"
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

  create_table "transferences", force: :cascade do |t|
    t.bigint "sender_id"
    t.bigint "receiver_id"
    t.bigint "user_id", null: false
    t.date "date", null: false
    t.integer "value_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_transferences_on_receiver_id"
    t.index ["sender_id"], name: "index_transferences_on_sender_id"
    t.index ["user_id"], name: "index_transferences_on_user_id"
  end

  create_table "user_reports", force: :cascade do |t|
    t.date "date"
    t.integer "savings_cents", default: 0, null: false
    t.integer "investments_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.integer "incomes_cents", default: 0, null: false
    t.integer "expenses_cents", default: 0, null: false
    t.integer "invested_cents", default: 0, null: false
    t.integer "balance_cents", default: 0, null: false
    t.integer "card_expenses_cents", default: 0, null: false
    t.integer "dividends_cents", default: 0, null: false
    t.string "reference", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "reference"], name: "index_user_reports_on_user_id_and_reference", unique: true
    t.index ["user_id"], name: "index_user_reports_on_user_id"
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
  add_foreign_key "dividends", "investments"
  add_foreign_key "financings", "users"
  add_foreign_key "investments", "accounts"
  add_foreign_key "payments", "financings"
  add_foreign_key "transactions", "account_reports"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transferences", "users"
  add_foreign_key "user_reports", "users"
end
