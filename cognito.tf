resource "aws_cognito_user_pool" "pool" {
  name = "WildRydes"

  mfa_configuration = "OFF"


  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject = "Confirm your email to continue"
    email_message = "Your verification code is {####}"
  }

  auto_verified_attributes = [ "email" ]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }


}

resource "aws_cognito_user_pool_client" "WildRydesWebApp" {
  name                    = "WildRydesWebApp"
  user_pool_id            = aws_cognito_user_pool.pool.id
  generate_secret         = false
}