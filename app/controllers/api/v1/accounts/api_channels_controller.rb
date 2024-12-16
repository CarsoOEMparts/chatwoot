class Api::V1::Accounts::ApiChannelsController < Api::V1::Accounts::BaseController
  before_action :check_authorization, only: [:index, :show]
  before_action :fetch_api_channel, only: [:show]

  def index
    @api_channels = if current_user.is_a?(SuperAdmin)
                     Channel::Api.all
                   else
                     Current.account.channel_api
                   end

    @api_channels = apply_additional_attributes_filter(@api_channels)
    
    render json: {
      payload: @api_channels.as_json(
        only: [:id, :identifier, :webhook_url, :hmac_mandatory, :additional_attributes, :created_at, :updated_at]
      )
    }
  end

  def show
    render json: {
      payload: @api_channel.as_json(
        only: [:id, :identifier, :webhook_url, :hmac_mandatory, :additional_attributes, :created_at, :updated_at]
      )
    }
  end

  private

  def fetch_api_channel
    @api_channel = if current_user.is_a?(SuperAdmin)
                    Channel::Api.find(params[:id])
                  else
                    Current.account.channel_api.find(params[:id])
                  end
  end

  def check_authorization
    return if current_user.is_a?(SuperAdmin)
    authorize(Channel::Api)
  end

  def apply_additional_attributes_filter(scope)
    return scope unless params[:additional_attributes].present?

    params[:additional_attributes].each do |key, value|
      scope = scope.where("additional_attributes ->> ? = ?", key, value.to_s)
    end
    scope
  end
end 