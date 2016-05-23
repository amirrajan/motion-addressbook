module AddressBook
  module Common
    module PublicInterface
      module ContactAccessor
        #####################
        ## Contacts Access ##
        #####################

        def connect(&after_connect)
          raise "connect(&after_connect) must be implemented"
        end

        def connected?
          raise "connected? must be implemented"
        end

        def request_authorization(&block)
          raise "request_authorization(&block) must be implemented"
        end

        ######################
        ## Entity Accessors ##
        ######################

        # Groups

        def groups(&callback)
          with_connection(:connected_groups, &callback)
        end

        def groups_count(&callback)
          with_connection(:connected_groups_count, &callback)
        end

        def group_new(attributes, &callback)
          with_connection(:connected_groups_new, attributes, &callback)
        end

        def group_create(attributes, &callback)
          with_connection(:connected_groups_create, attributes, &callback)
        end

        def group_find(id, &callback)
          with_connection(:connected_groups_find, id, &callback)
        end

        # People

        def contacts(options = {}, &callback)
          with_connection(:connected_contacts, options, &callback)
        end
        alias :people :contacts

        def contacts_changed_since(timestamp, &callback)
          with_connection(:connected_contacts_changed_since, timestamp, &callback)
        end
        alias :people_changed_since :contacts_changed_since

        def contacts_count(&callback)
          with_connection(:connected_contacts_count, &callback)
        end
        alias :people_count :contacts_count

        def contacts_where(conditions, &callback)
          with_connection(:connected_contacts_where, conditions, &callback)
        end
        alias :people_where :contacts_where

        def contact_new(attributes, &callback)
          with_connection(:connected_contacts_new, attributes, &callback)
        end
        alias :person_new :contact_new

        def contact_create(attributes, &callback)
          with_connection(:connected_contacts_create, attributes, &callback)
        end
        alias :person_create :contact_create

        def contact_find(id, &callback)
          with_connection(:connected_contacts_find, id, &callback)
        end
        alias :person_find :contact_find

        # Sources

        def sources(&callback)
          with_connection(:connected_sources_index, &callback)
        end

        private

        def ensure_connection!(&after_connect)
          connected? ? after_connect.call : connect(&after_connect)
        end

        def with_connection(method_name, *args, &callback)
          ensure_connection! { callback.call(send(method_name, *args)) }
        end
      end
    end
  end
end
