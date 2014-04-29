class ContentController < ApplicationController
  before_filter :restrict_request_format

  def show
    # TODO: should we auto-convert the params[:id] to include the leading slash?
    @artefact = ContentArtefact.find_by(:base_path => params[:id])
    render :json => @artefact
  end

  def update
    @artefact = ContentArtefact.find_or_initialize_by(:base_path => params[:id])
    status_code = @artefact.new_record? ? 201 : 200
    if @artefact.update_attributes(params[:content])
      render :json => @artefact, :status => status_code
    else
      render :json => @artefact, :status => 422
    end
  end

  def destroy
    if @artefact.destroy
      render :json => @artefact
    else
      render :json => @artefact, :status => 422
    end
  end

private

  def restrict_request_format
    request.format = :json
  end
end
