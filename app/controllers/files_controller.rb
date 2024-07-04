class FilesController < ApplicationController
  before_action :authenticate_user!

  def file_upload; end

  def upload
    FilesServices::ProcessFile.call(params[:file], current_user.id)
    redirect_to summary_path, notice: 'File uploaded succesfully.'
  rescue StandardError
    redirect_to file_upload_path, notice: 'File not uploaded.'
  end
end
