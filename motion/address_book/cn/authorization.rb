module AddressBook
  module CN
    module Authorization
      class << self
        def ENTITY_MAP
          { contacts: CNEntityTypeContacts }
        end

        def STATUS_MAP
          {
            CNAuthorizationStatusNotDetermined => :not_determined,
            CNAuthorizationStatusRestricted => :restricted,
            CNAuthorizationStatusDenied => :denied,
            CNAuthorizationStatusAuthorized => :authorized
          }
        end

        def granted?
          status == :authorized
        end

        def request(&callback)
          instance.requestAccessForEntityType(self.ENTITY_MAP[:contacts],
            completionHandler: callback
          )
        end

        def status
          self.STATUS_MAP[
            Accessors::ContactStore.status_for_type(self.ENTITY_MAP[:contacts])
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
