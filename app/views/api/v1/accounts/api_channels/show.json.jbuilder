json.payload do
  json.id @api_channel.id
  json.identifier @api_channel.identifier
  json.webhook_url @api_channel.webhook_url
  json.hmac_mandatory @api_channel.hmac_mandatory
  json.additional_attributes @api_channel.additional_attributes
  json.created_at @api_channel.created_at
  json.updated_at @api_channel.updated_at
end