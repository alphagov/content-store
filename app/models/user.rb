class User < ApplicationRecord
  include GDS::SSO::User
end
