module TransferenceServices
  class FetchTransferences
    def initialize(user_id)
      @user_id = user_id
    end

    def self.call(user_id)
      new(user_id).call
    end

    def call
      Transference.where(user_id: user_id)
                  .includes(:sender, :receiver)
                  .order(date: :desc)
                  .limit(10)
    end

    private

    attr_reader :user_id
  end
end
