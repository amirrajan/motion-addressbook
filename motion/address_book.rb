module AddressBook
  class << self
    attr_writer :auto_connect

    def instance
      Dispatch.once { @contact_accessor ||= create_contact_accessor }
      @contact_accessor
    end

    def authorized?
      auth_handler.granted?
    end

    # Will return one of the following:
    # :not_determined, :restricted, :denied, :authorized
    def authorization_status
      auth_handler.status
    end

    def can_attempt_access?
      [:authorized, :not_determined].include? authorization_status
    end

    def framework_as_sym
      case UIDevice.currentDevice.systemVersion.to_i
      when 6, 7, 8 then :ab # ABAddressBook - https://goo.gl/2Xbebu
      when 9 then :cn       # CNContact - https://goo.gl/RDAlRw
      else raise "This iOS is not supported by motion-addressbook"
      end
    end

    def respond_to?(method_name, include_private = false)
      instance.respond_to?(method_name, include_private) || super
    end

    private

    def auto_connect
      @auto_connect || true
    end

    def create_contact_accessor
      case framework_as_sym
      when :ab then AB::AddressBook.new(auto_connect)
      when :cn then CN::ContactStore.new(auto_connect)
      end
    end

    def auth_handler
      case framework_as_sym
      when :ab then AB::Authorization
      when :cn then CN::Authorization
      end
    end

    def method_missing(method_name, *args, &block)
      return super unless instance.respond_to?(method_name)
      instance.send(method_name, *args, &block)
    end
  end
end
::Contacts = AddressBook unless defined?(::Contacts)
