module AddressBook
  module CN
    module Authorization
      STATUS_MAP = {
        CNAuthorizationStatusNotDetermined => :not_determined,
        CNAuthorizationStatusRestricted => :restricted,
        CNAuthorizationStatusDenied => :denied,
        CNAuthorizationStatusAuthorized => :authorized
      }

      class << self
        def granted?
          status == :authorized
        end

        def request(&callback)
          CNContactStore.requestAccessForEntityType(CNEntityTypeContacts,
            completionHandler: callback
          )
        end

        def status
          STATUS_MAP[status_for_type(CNEntityTypeContacts)]
        end

        private

        def status_for_type(entity_type)
          CNContactStore.authorizationStatusForEntityType entity_type
        end
      end
    end
  end
end
