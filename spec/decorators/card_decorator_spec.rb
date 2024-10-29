require 'rails_helper'

RSpec.describe CardDecorator, type: :decorator do
  let(:card) { create(:account, :card) }
  let(:decorated_card) { CardDecorator.decorate(card) }

  describe '#balance' do
    it 'formats the card balance' do
      expect(decorated_card.balance).to eq(ActionController::Base.helpers.number_to_currency(card.balance, unit: 'R$ ', separator: ',', delimiter: '.'))
    end
  end

  describe '#current_report' do
    it 'decorates the current report' do
      expect(decorated_card.current_report).to be_a(AccountReportDecorator)
    end
  end

  describe '#past_reports' do
    it 'fetches and decorates past reports' do
      past_reports = decorated_card.past_reports
      expect(past_reports).to all(be_a(AccountReportDecorator))
    end
  end

  describe '#future_reports' do
    it 'fetches and decorates future reports' do
      future_reports = decorated_card.future_reports
      expect(future_reports).to all(be_a(AccountReportDecorator))
    end
  end

  describe '#transactions' do
    it 'decorates transactions' do
      transaction = create(:transaction, account: card)
      expect(decorated_card.transactions).to all(be_a(TransactionDecorator))
    end
  end

  describe '#account_reports' do
    it 'decorates account reports' do
      account_report = create(:account_report, account: card)
      expect(decorated_card.account_reports).to all(be_a(AccountReportDecorator))
    end
  end
end
