module AddressBook
  module Common
    module PublicInterface
      module Contact
        include Hashable

        AB_ATTRIBUTES = [
          # Single-values
          :birthday,
          :creation_date,
          :department,
          :first_name,
          :job_title,
          :last_name,
          :middle_name,
          :modification_date,
          :nickname,
          :note,
          :organization,
          :prefix,
          :suffix,
          # Multi-values
          :addresses,
          :dates,
          :emails,
          :im_profiles,
          :phones,
          :relations,
          :social_profiles,
          :urls
        ]

        CN_ATTRIBUTES = [
          # Single-values
          :birthday,
          :contact_type,
          :department,
          :first_name_phonetic,
          :first_name,
          :image_available,
          :image,
          :job_title,
          :last_name_phonetic,
          :last_name,
          :maiden_name,
          :middle_name_phonetic,
          :middle_name,
          :nickname,
          :non_gregorian_birthday,
          :note,
          :organization,
          :prefix,
          :suffix,
          :thumbnail_image,
          # Multi-values
          :addresses,
          :dates,
          :emails,
          :im_profiles,
          :phones,
          :relations,
          :social_profiles,
          :urls
        ]

        ATTRIBUTES_SUPERSET = (AB_ATTRIBUTES + CN_ATTRIBUTES).uniq

        def attributes
          to_h.tap do |hash|
            ATTRIBUTES_SUPERSET.each do |attribute|
              hash[attribute] ||= send(attribute)
            end
          end
        end
      end
    end
  end
end
