module AddressBook
  AB_STATUS_MAP = {
    KABAuthorizationStatusNotDetermined => :not_determined,
    KABAuthorizationStatusRestricted => :restricted,
    KABAuthorizationStatusDenied => :denied,
    KABAuthorizationStatusAuthorized => :authorized
  }

  CN_STATUS_MAP = {
    CNAuthorizationStatusNotDetermined => :not_determined,
    CNAuthorizationStatusRestricted => :restricted,
    CNAuthorizationStatusDenied => :denied,
    CNAuthorizationStatusAuthorized => :authorized
  }

  class << self
    def address_book
      @address_book ||= begin
        if Kernel.const_defined?(:NSApplication)
          ABAddressBook.addressBook
        else # iOS
          case ios_version
          when 5 then ios5_create
          when 6, 7, 8 then ios6_create
          else ios9_create
          end
        end
      end
    end

    def instance
      @instance ||= AddrBook.new
    end

    def count
      return instance.count if Kernel.const_defined?(:UIApplication)

      address_book.count
    end

    def request_authorization(&block)
      synchronous = !block

      return (synchronous ? block.call(true) : true) if ios_version < 6

      access_callback = lambda { |granted, error|
        NSLog "%@", granted
        NSLog "%@", error
        # not sure what to do with error ... so we're ignoring it
        @address_book_access_granted = granted
        block.call(@address_book_access_granted) unless block.nil?
      }

      case ios_version
      when 6, 7, 8
        ABAddressBookRequestAccessWithCompletion(@address_book, access_callback)
      else
        address_book.requestAccessForEntityType(CNEntityTypeContacts,
          completionHandler: access_callback
        )
      end

      # Wait on the asynchronous callback before returning.
      while(synchronous && @address_book_access_granted.nil?) do sleep 0.1 end

      @address_book_access_granted
    end

    def authorized?
      authorization_status == :authorized
    end

    def authorization_status
      case ios_version
      when 5 then :authorized
      when 6, 7, 8 then AB_STATUS_MAP[ABAddressBookGetAuthorizationStatus()]
      else
        CN_STATUS_MAP[
          CNContactStore.authorizationStatusForEntityType(CNEntityTypeContacts)
        ]
      end
    end

    def create_with_options_available?
      error = nil
      ABAddressBookCreateWithOptions(nil, error) rescue false
    end

    private

    def ios5_create
      @address_book = ABAddressBookCreate()
    end

    def ios6_create
      error = nil
      if authorized?
        @address_book = ABAddressBookCreateWithOptions(nil, error)
      else
        request_authorization do |rc|
          NSLog "AddressBook: access was #{rc ? 'approved' : 'denied'}"
        end
      end
      @address_book
    end

    def ios9_create
      @address_book = CNContactStore.new
    end

    def ios_version
      UIDevice.currentDevice.systemVersion.to_i
    end
  end
end
