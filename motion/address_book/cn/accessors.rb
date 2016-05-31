module AddressBook; module CN; module Accessors

  module Contacts
    CONTACTS_PER_BATCH = 100.freeze
    THREADS = 8.freeze

    class << self
      def all_identifiers(connection)
        contacts, error = [[], nil]
        fetch_request =
          CNContactFetchRequest.alloc.initWithKeysToFetch(["identifier"])
        fetch_request.unifyResults = true
        fetch_request.predicate = nil

        connection.enumerateContactsWithFetchRequest(
          fetch_request,
          error: error,
          usingBlock: proc { |contact, _cursor| contacts << contact }
        )
        error ? raise(error) : contacts.map { |contact| contact.identifier }
      end

      def index(connection, &callback)
        identifiers = all_identifiers(connection)

        identifiers.each_slice(ids_per_thread(identifiers)) do |contact_ids|
          async_fetch(connection, contact_ids, callback)
        end
      end

      def new_record
        CNMutableContact()
      end

      private

      def async_fetch(connection, contact_ids, callback)
        return unless contact_ids && contact_ids.is_a?(Array)

        Dispatch::Queue.concurrent.async do
          contact_ids.each_slice(CONTACTS_PER_BATCH) do |contact_ids|
            fetch_slice connection, contact_ids, &callback
          end
        end
      end

      def contacts_from_predicate(connection, predicate)
        contacts, error = [[], nil]

        contacts = connection.unifiedContactsMatchingPredicate(
          predicate,
          keysToFetch: CN::Contact::ALL_PROPERTIES.keys,
          error: error
        )

        [contacts, error]
      end

      def fetch_slice(connection, contact_ids, &callback)
        return unless contact_ids && contact_ids.is_a?(Array)

        contacts, error =
          contacts_from_predicate(connection, predicate_for_ids(contact_ids))

        Dispatch::Queue.main.async { callback.call(contacts, error) }
      end

      def ids_per_thread(ids)
        ids.count > THREADS ? (ids.count / THREADS).ceil : ids.count
      end

      def predicate_for_ids(id_array)
        CNContact.predicateForContactsWithIdentifiers(id_array)
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

end; end; end
