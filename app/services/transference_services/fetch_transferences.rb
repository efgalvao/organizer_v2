module TransferenceServices
  module FetchTransferences
    module_function

    def call(user_id)
      TransferenceRepository.new.all(user_id)
    end
  end
end
