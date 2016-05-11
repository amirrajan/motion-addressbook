module AddressBook
  class << self
    def instance(autoconnect = true)
      Dispatch.once { @address_book ||= address_book(autoconnect) }
      @address_book
    end

    def respond_to?(method_name, include_private = false)
      instance.respond_to?(method_name, include_private) || super
    end

    def framework_as_sym
      case UIDevice.currentDevice.systemVersion.to_i
      # Use ABAddressBook (iOS < 9) - https://goo.gl/2Xbebu
      when 6, 7, 8 then :ab
      # Use CNContact (iOS >= 9) - https://goo.gl/RDAlRw
      when 9 then :cn
      else raise "This iOS is not supported by motion-addressbook"
      end
    end

    private

    def address_book(autoconnect)
      # OSX
      return ABAddressBook.addressBook if Kernel.const_defined? :NSApplication

      # iOS
      return unless address_book_class.respond_to? :new

      address_book_class.new(autoconnect)
    end

    def address_book_class
      case AddressBook.framework_as_sym
      when :ab then AB::AddressBook
      when :cn then nil
      end
    end

    def method_missing(method_name, *args, &block)
      return super unless instance.respond_to?(method_name)
      instance.send(method_name, *args, &block)
    end
  end
end
