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

          def new_record
            CNMutableContact()
          end

          private

          def fetch_request
            CNContactFetchRequest.alloc.initWithKeysToFetch(
              CN::Contact::ALL_PROPERTIES.keys
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

      module LabeledValue
        class << self
          def new(label, value)
            CNLabeledValue.initWithLabel(label, value: value)
          end
        end
      end

    end
  end
end
