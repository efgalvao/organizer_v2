module TransferenceServices
  module FetchTransferences
    module_function

    def call(user_id)
      Transference.where(user_id: user_id)
                  .includes(:sender, :receiver)
                  .order(date: :desc)
                  .limit(10)
    end
  end
end
