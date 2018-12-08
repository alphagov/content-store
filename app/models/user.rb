class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include GDS::SSO::User

  field "name",                    type: String
  field "uid",                     type: String
  field "email",                   type: String
  field "permissions",             type: Array
  field "remotely_signed_out",     type: Boolean, default: false
  field "organisation_slug",       type: String
  field "disabled",                type: Boolean, default: false
  field "organisation_content_id", type: String

  index({ uid: 1 }, { unique: true })
  index disabled: 1
end
