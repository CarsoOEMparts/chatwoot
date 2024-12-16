class Channel::ApiPolicy < ApplicationPolicy
  def index?
    return true if user.is_a?(SuperAdmin)
    return true if @account_user&.administrator?
    @account_user&.has_permission?(:view_api_channels)
  end

  def show?
    return true if user.is_a?(SuperAdmin)
    return true if @account_user&.administrator?
    @account_user&.has_permission?(:view_api_channels)
  end

  # Add other actions as needed
end 