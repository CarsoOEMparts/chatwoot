class Public::Api::V1::Inboxes::MessagesController < Public::Api::V1::InboxesController
  before_action :set_message, only: [:update]

  def index
    @messages = @conversation.nil? ? [] : message_finder.perform
  end

  def create
    @message = @conversation.messages.new(message_params)
    build_attachment
    @message.save!
    
    # Set custom created_at if external_created_at is provided
    handle_external_created_at if params[:external_created_at].present?
  end

  def update
    render json: { error: 'You cannot update the CSAT survey after 14 days' }, status: :unprocessable_entity and return if check_csat_locked

    @message.update!(message_update_params)
  rescue StandardError => e
    render json: { error: @contact.errors, message: e.message }.to_json, status: :internal_server_error
  end

  private

  def handle_external_created_at
    timestamp = parse_external_timestamp(params[:external_created_at])
    return unless timestamp

    # Update message created_at
    @message.update_columns(created_at: timestamp)
    
    # Update message content_attributes to store original external_created_at
    content_attrs = @message.content_attributes || {}
    content_attrs['external_created_at'] = params[:external_created_at]
    @message.update_columns(content_attributes: content_attrs)
    
    # Only update conversation's last_activity_at if the external timestamp is newer
    if @conversation.last_activity_at.nil? || timestamp > @conversation.last_activity_at
      @conversation.update_columns(last_activity_at: timestamp)
    end
  end

  def parse_external_timestamp(timestamp_str)
    Time.parse(timestamp_str)
  rescue ArgumentError, TypeError
    nil
  end

  def build_attachment
    return if params[:attachments].blank?

    params[:attachments].each do |uploaded_attachment|
      @message.attachments.new(
        account_id: @message.account_id,
        file_type: helpers.file_type(uploaded_attachment&.content_type),
        file: uploaded_attachment
      )
    end
  end

  def message_finder_params
    {
      filter_internal_messages: true,
      before: params[:before]
    }
  end

  def message_finder
    @message_finder ||= MessageFinder.new(@conversation, message_finder_params)
  end

  def message_update_params
    params.permit(:content, submitted_values: [:name, :title, :value, { csat_survey_response: [:feedback_message, :rating] }])
  end

  def permitted_params
    params.permit(:content, :echo_id, :source_id, :external_created_at)
  end

  def set_message
    @message = @conversation.messages.find(params[:id])
  end

  def message_params
    {
      account_id: @conversation.account_id,
      sender: @contact_inbox.contact,
      content: permitted_params[:content],
      source_id: permitted_params[:source_id],
      inbox_id: @conversation.inbox_id,
      echo_id: permitted_params[:echo_id],
      message_type: :incoming
    }
  end

  def check_csat_locked
    (Time.zone.now.to_date - @message.created_at.to_date).to_i > 14 and @message.content_type == 'input_csat'
  end
end
