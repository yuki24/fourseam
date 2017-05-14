require "delegate"

module Fourseam
  class NotificationDelivery < Delegator
    def initialize(notifier_class, action, *args) #:nodoc:
      @notifier_class, @action, @args = notifier_class, action, args

      # The notification is only processed if we try to call any methods on it.
      # Typical usage will leave it unloaded and call deliver_later.
      @processed_notifier = nil
      @notification_message = nil
    end

    def __getobj__ #:nodoc:
      @notification_message ||= processed_notifier.notification
    end

    # Unused except for delegator internals (dup, marshaling).
    def __setobj__(notification_message) #:nodoc:
      @notification_message = notification_message
    end

    def message
      __getobj__
    end

    def processed?
      @processed_notifier || @notification_message
    end

    def deliver_later!(options = {})
      enqueue_delivery :deliver_now!, options
    end

    def deliver_now!
      processed_notifier.handle_exceptions { do_deliver }
    end

    private

    def do_deliver
      @notifier_class.inform_interceptors(self)

      responses = nil
      @notifier_class.deliver_notification(self) do
        # TODO: reference to Fourseam...?
        responses = ::Fourseam::Base.config.each do |platform, config|
          Adapters.lookup(config.adapter).new(config).push!(message[platform]) if message[platform]
        end
      end

      @notifier_class.inform_observers(self)
      responses
    end

    def processed_notifier
      @processed_notifier ||= @notifier_class.new.tap do |notifier|
        notifier.process @action, *@args
      end
    end

    def enqueue_delivery(delivery_method, options = {})
      if processed?
        ::Kernel.raise "You've accessed the message before asking to " \
                       "deliver it later, so you may have made local changes that would " \
                       "be silently lost if we enqueued a job to deliver it. Why? Only " \
                       "the notifier method *arguments* are passed with the delivery job! " \
                       "Do not access the message in any way if you mean to deliver it " \
                       "later. Workarounds: 1. don't touch the message before calling " \
                       "#deliver_later, 2. only touch the message *within your notifier " \
                       "method*, or 3. use a custom Active Job instead of #deliver_later."
      else
        args = @notifier_class.name, @action.to_s, delivery_method.to_s, *@args
        ::Fourseam::DeliveryJob.set(options).perform_later(*args)
      end
    end
  end
end
