Pushing::Platforms.configure do |config|
  config.fcm.adapter    = Rails.env.test? ? :test : :andpush
  config.fcm.server_key = 'YOUR_FCM_TEST_SERVER_KEY'

  config.apn.environment          = Rails.env.production? ? :production : :development
  config.apn.adapter              = Rails.env.test? ? :test : :apnotic
  config.apn.topic                = 'com.awesomecompany.app'
  config.apn.certificate_path     = '/config/your_certificate.pem'
  config.apn.certificate_password = 'PASSWORD_FOR_CERT'
end