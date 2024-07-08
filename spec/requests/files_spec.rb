require 'rails_helper'

RSpec.describe 'File' do
  let(:user) { create(:user) }

  describe 'GET /file_upload' do
    context 'when logged in' do
      it 'can successfully access file upload page' do
        sign_in(user)

        get file_upload_path

        expect(response).to be_successful
      end
    end

    context 'when not logged in' do
      it 'can not access file upload page' do
        get file_upload_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST /upload' do
    let(:new_upload) { post upload_path, params: { file: 'abc.txt' } }

    before { sign_in(user) }

    context 'with valid data' do
      before { allow(FilesServices::ProcessFile).to receive(:call).with(any_args).and_return(true) }

      it 'has flash notice' do
        new_upload

        expect(flash[:notice]).to eq('File uploaded succesfully.')
      end

      it 'redirects to summary_path' do
        new_upload

        expect(response).to redirect_to summary_path
      end
    end

    context 'with invalid data' do
      it 'has flash notice' do
        allow(FilesServices::ProcessFile).to receive(:call).with(any_args).and_raise(StandardError)

        new_upload

        expect(flash[:notice]).to eq('File not uploaded.')
      end
    end
  end
end
