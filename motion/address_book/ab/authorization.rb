module AddressBook
  module AB
    module Authorization
      STATUS_MAP = {
        KABAuthorizationStatusNotDetermined => :not_determined,
        KABAuthorizationStatusRestricted => :restricted,
        KABAuthorizationStatusDenied => :denied,
        KABAuthorizationStatusAuthorized => :authorized
      }

      class << self
        def granted?
          status == :authorized
        end

        def request(pointer, &callback)
          ABAddressBookRequestAccessWithCompletion(pointer, callback)
        end

        def status
          STATUS_MAP[ABAddressBookGetAuthorizationStatus()]
        end
      end
    end
  end
end
