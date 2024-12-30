require 'rails_helper'

RSpec.describe Account::CardDecorator, type: :decorator do
  let(:card) { create(:account, :card) }
  let(:decorated_card) { described_class.decorate(card) }

  describe '#balance' do
    it 'formats the card balance' do
      expect(decorated_card.balance).to eq(ActionController::Base.helpers.number_to_currency(card.balance, unit: 'R$ ', separator: ',', delimiter: '.'))
    end
  end

  describe '#current_report' do
    it 'decorates the current report' do
      expect(decorated_card.current_report).to be_a(Account::AccountReportDecorator)
    end
  end

  describe '#past_reports' do
    it 'fetches and decorates past reports' do
      past_reports = decorated_card.past_reports
      expect(past_reports).to all(be_a(Account::AccountReportDecorator))
    end
  end

  describe '#future_reports' do
    it 'fetches and decorates future reports' do
      future_reports = decorated_card.future_reports
      expect(future_reports).to all(be_a(Account::AccountReportDecorator))
    end
  end

  describe '#transactions' do
    it 'decorates transactions' do
      create(:transaction, account: card)
      expect(decorated_card.transactions).to all(be_a(Account::TransactionDecorator))
    end
  end

  describe '#account_reports' do
    it 'decorates account reports' do
      create(:account_report, account: card)
      expect(decorated_card.account_reports).to all(be_a(Account::AccountReportDecorator))
    end
  end

  describe '#broker?' do
    it 'returns true if the account is a broker' do
      broker = create(:account, :broker)
      decorated_broker = described_class.decorate(broker)
      expect(decorated_broker.broker?).to be(true)
    end

    it 'returns false if the account is not a broker' do
      expect(decorated_card.broker?).to be(false)
    end
  end

  describe '#back_path' do
    it 'returns the path to the card' do
      expect(decorated_card.back_path).to eq("/cards/#{card.id}")
    end
  end

  describe '#report_date' do
    it 'returns the report date' do
      expect(decorated_card.date).to eq(card.current_report.report_date)
    end
  end
end
