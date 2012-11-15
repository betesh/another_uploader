class UploadsController < ApplicationController
  def uploadify
    @upload = Upload.new
    respond_to do |format|
      format.js { render nothing: true }
    end
  end

  def destroy
    @upload = Upload.find(params[:id])
    respond_to do |format|
      format.js { render nothing: true }
    end
  end
end
