module AddressBook
  module CN
    module Authorization
      ENTITY_MAP = { contacts: CNEntityTypeContacts }
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
          instance.requestAccessForEntityType(ENTITY_MAP[:contacts],
            completionHandler: callback
          )
        end

        def status
          STATUS_MAP[
            Accessors::ContactStore.status_for_type(ENTITY_MAP[:contacts])
          ]
        end

        private

        def instance
          @instance ||= Accessors::ContactStore.new_connection
        end
      end
    end
  end
end
