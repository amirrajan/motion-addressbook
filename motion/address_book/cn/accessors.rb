module AddressBook
  module CN
    module Accessors

      module Contacts
        class << self
          def index(connection)
            contacts, error = [[], nil]
            connection.enumerateContactsWithFetchRequest(
              fetch_request,
              error: error,
              usingBlock: proc { |contact, _stop| contacts << contact }
            )
            error ? raise(error) : contacts
          end

          private

          def fetch_request
            CNContactFetchRequest.alloc.initWithKeysToFetch(
              CN::Contact::PROPERTY_MAP.keys
            )
          end
        end
      end

      module ContactStore
        class << self
          def containers
            error = nil
            new_connection.containersMatchingPredicate(nil, error: error)
            raise(error) if error
          end

          def new_connection
            CNContactStore.new
          end
        end
      end

    end
  end
end
