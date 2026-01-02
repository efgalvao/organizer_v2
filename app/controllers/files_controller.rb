class FilesController < ApplicationController
  before_action :authenticate_user!

  def file_upload; end

  def upload
    FilesServices::ProcessFile.call(upload_params, current_user.id)
    redirect_to summary_path, notice: I18n.t('files.file_upload.success')
  rescue StandardError => e
    redirect_to file_upload_path, notice: I18n.t('files.file_upload.failure')
  end

  private

  def upload_params
    params.require(:upload).permit(:file, :origin, :account_id)
  end
end
