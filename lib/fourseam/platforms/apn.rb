module Fourseam
  module PlatformSupport
    # TODO: Rename it to ApnSettings
    class Apn
      attr_accessor :adapter, :certificate_path, :environment

      def initialize(*)
        @environment = 'development' # TODO: Use Rails.env to figure out the RAILS_ENV
      end

      def certificate
        @certificate ||= File.read(certificate_path)
      end

      class Payload
        attr_reader :device_token

        def initialize(payload, device_token)
          @payload, @device_token = payload, device_token
        end

        # TODO: You shouldn't have to parse the json
        def payload
          JSON.parse(@payload, symbolize_names: true)
        end
      end
    end
  end
end
