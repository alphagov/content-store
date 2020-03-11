class AddSignupTypeToEmailAlertSignups < Mongoid::Migration
  def self.up
    ContentItem.any_of({ base_path: /.*government.*email-signup.*/, rendering_app: "email-alert-frontend" }).each do |policy_email_signup|
      policy_email_signup.details[:email_alert_type] = "policies"
      policy_email_signup.save!
    end
  end

  def self.down
    ContentItem.any_of({ base_path: /.*government.*email-signup.*/, rendering_app: "email-alert-frontend" }).each do |policy_email_signup|
      policy_email_signup.details.delete("email_alert_type")
      policy_email_signup.save!
    end
  end
end
