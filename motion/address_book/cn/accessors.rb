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

          def status_for_type(entity_type)
            CNContactStore.authorizationStatusForEntityType entity_type
          end
        end
      end

      module LabeledValue
        class << self
          def new_address(label, value_object)
            address = CNPostalAddress.alloc.init
            value_object.each do |key, value|
              new_value = value || "" # Empty string clears the value
              address.send("#{key}=", new_value)
            end
            CNLabeledValue.initWithLabel(label, value: address)
          end

          def new_im_address(label, value_object)
            im_address = CNInstantMessageAddress.initWithUsername(
              value_object[:username],
              service: value_object[:service]
            )
            CNLabeledValue.initWithLabel(label, value: im_address)
          end

          def new_phone(label, value_object)
            phone = CNPhoneNumber.initWithStringValue(value_object[:number])
            CNLabeledValue.initWithLabel(label, value: phone)
          end

          def new_relation(label, value_object)
            relation = CNContactRelation.initWithName(value_object[:name])
            CNLabeledValue.initWithLabel(label, value: relation)
          end

          def new_social_profile(label, value_object)
            social_profile = CNSocialProfile.initWithUrlString(
              value_object[:urlString],
              username: value_object[:username],
              userIdentifier: value_object[:userIdentifier],
              service: value_object[:service],
              displayname: nil
            )
            CNLabeledValue.initWithLabel(label, value: social_profile)
          end

          def new_value(label, value_object)
            CNLabeledValue.initWithLabel(label, value: value_object[:value])
          end
        end
      end

    end
  end
end
