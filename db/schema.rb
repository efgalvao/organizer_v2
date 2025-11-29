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

ActiveRecord::Schema[7.0].define(version: 2025_11_22_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_reports", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.date "date"
    t.decimal "initial_account_balance", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "final_account_balance", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "month_balance", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "month_income", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "month_expense", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "month_invested", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "month_earnings", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reference"
    t.decimal "invoice_payment", precision: 10, scale: 2, default: "0.0"
    t.index ["account_id"], name: "index_account_reports_on_account_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.decimal "balance", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "kind", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
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
    t.decimal "amount", precision: 15, scale: 2, default: "0.0", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shares"
    t.index ["investment_id"], name: "index_dividends_on_investment_id"
  end

  create_table "financings", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "borrowed_value", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "installments", default: 0, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_financings_on_user_id"
  end

  create_table "interest_on_equities", force: :cascade do |t|
    t.bigint "investment_id", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["investment_id"], name: "index_interest_on_equities_on_investment_id"
  end

  create_table "investments", force: :cascade do |t|
    t.string "type", null: false
    t.string "name", null: false
    t.decimal "invested_amount", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "current_amount", precision: 15, scale: 2, default: "0.0", null: false
    t.boolean "released", default: false, null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shares_total", default: 0
    t.integer "kind", default: 7, null: false
    t.integer "bucket", default: 0, null: false
    t.index ["account_id"], name: "index_investments_on_account_id"
  end

  create_table "monthly_investments_reports", force: :cascade do |t|
    t.bigint "investment_id", null: false
    t.date "reference_date", null: false
    t.integer "starting_shares", default: 0, null: false
    t.decimal "starting_market_value", precision: 15, scale: 2, default: "0.0"
    t.integer "shares_bought", default: 0, null: false
    t.decimal "inflow_amount", precision: 15, scale: 2, default: "0.0"
    t.decimal "outflow_amount", precision: 15, scale: 2, default: "0.0"
    t.decimal "dividends_received", precision: 15, scale: 2, default: "0.0"
    t.integer "shares_sold", default: 0, null: false
    t.decimal "ending_market_value", precision: 15, scale: 2, default: "0.0"
    t.decimal "accumulated_inflow_amount", precision: 15, scale: 2, default: "0.0"
    t.decimal "average_purchase_price", precision: 15, scale: 4, default: "0.0"
    t.decimal "monthly_appreciation_value", precision: 15, scale: 2, default: "0.0"
    t.decimal "monthly_return_percentage", precision: 8, scale: 4, default: "0.0"
    t.decimal "accumulated_return_percentage", precision: 8, scale: 4, default: "0.0"
    t.decimal "portfolio_weight_percentage", precision: 8, scale: 4, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["investment_id", "reference_date"], name: "index_monthly_investments_reports_on_investment_and_date", unique: true
    t.index ["investment_id"], name: "index_monthly_investments_reports_on_investment_id"
  end

  create_table "negotiations", force: :cascade do |t|
    t.string "negotiable_type", null: false
    t.bigint "negotiable_id", null: false
    t.date "date"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0", null: false
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
    t.decimal "amortization", precision: 15, scale: 2, default: "0.0"
    t.decimal "interest", precision: 15, scale: 2, default: "0.0"
    t.decimal "insurance", precision: 15, scale: 2, default: "0.0"
    t.decimal "fees", precision: 15, scale: 2, default: "0.0"
    t.decimal "monetary_correction", precision: 15, scale: 2, default: "0.0"
    t.decimal "adjustment", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["financing_id"], name: "index_payments_on_financing_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "positionable_type", null: false
    t.bigint "positionable_id", null: false
    t.date "date"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "shares", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["positionable_type", "positionable_id"], name: "index_positions_on_positionable"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "account_report_id"
    t.bigint "category_id"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "kind", default: 0, null: false
    t.string "title", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group"
    t.string "type"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["account_report_id"], name: "index_transactions_on_account_report_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
  end

  create_table "transferences", force: :cascade do |t|
    t.bigint "sender_id"
    t.bigint "receiver_id"
    t.bigint "user_id", null: false
    t.date "date", null: false
    t.decimal "amount", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_transferences_on_receiver_id"
    t.index ["sender_id"], name: "index_transferences_on_sender_id"
    t.index ["user_id"], name: "index_transferences_on_user_id"
  end

  create_table "user_reports", force: :cascade do |t|
    t.date "date"
    t.decimal "savings", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "investments", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "incomes", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "expenses", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "invested", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "balance", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "card_expenses", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "earnings", precision: 15, scale: 2, default: "0.0", null: false
    t.string "reference", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "invoice_payments", precision: 10, scale: 2, default: "0.0"
    t.decimal "redeemed", precision: 10, scale: 2, default: "0.0"
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
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "account_reports", "accounts"
  add_foreign_key "accounts", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "dividends", "investments"
  add_foreign_key "financings", "users"
  add_foreign_key "interest_on_equities", "investments"
  add_foreign_key "investments", "accounts"
  add_foreign_key "monthly_investments_reports", "investments"
  add_foreign_key "payments", "financings"
  add_foreign_key "transactions", "account_reports"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transferences", "users"
  add_foreign_key "user_reports", "users"
end
