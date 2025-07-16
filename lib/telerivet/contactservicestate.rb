
module Telerivet

#
# Represents the current state of a particular contact for a particular Telerivet service.
# 
# Some automated services (including polls) are 'stateful'. For polls,
# Telerivet needs to keep track of which question the contact is currently answering, and
# stores store the ID of each contact's current question (e.g. 'q1' or 'q2') as the ID of the
# contact's state for the poll service. Any type of conversation-like service will also need
# to store state for each contact.
# 
# For this type of entity, the 'id' field is NOT a read-only unique ID (unlike
# all other types of entities). Instead it is an arbitrary string that identifies the
# contact's current state within your poll/conversation; many contacts may have the same state
# ID, and it may change over time. Additional custom fields may be stored in the 'vars'.
# 
# Initially, the state 'id' for any contact is null. When saving the state,
# setting the 'id' to null is equivalent to resetting the state (so all 'vars' will be
# deleted); if you want to save custom variables, the state 'id' must be non-null.
# 
# Many Telerivet services are stateless, such as auto-replies or keyword-based
# services where the behavior only depends on the current message, and not any previous
# messages sent by the same contact. Telerivet doesn't store any state for contacts that
# interact with stateless services.
# 
# Fields:
# 
#   - id (string, max 63 characters)
#       * Arbitrary string representing the contact's current state for this service, e.g.
#           'q1', 'q2', etc.
#       * Updatable via API
#   
#   - contact_id
#       * ID of the contact
#       * Read-only
#   
#   - service_id
#       * ID of the service
#       * Read-only
#   
#   - vars (Hash)
#       * Custom variables stored for this contact/service state. Variable names may be up to
#           32 characters in length and can contain the characters a-z, A-Z, 0-9, and _.
#           Values may be strings, numbers, or boolean (true/false).
#           String values may be up to 4096 bytes in length when encoded as UTF-8.
#           Up to 100 variables are supported per object.
#           Setting a variable to null will delete the variable.
#       * Updatable via API
#   
#   - time_created (UNIX timestamp)
#       * Time the state was first created in Telerivet
#       * Read-only
#   
#   - time_updated (UNIX timestamp)
#       * Time the state was last updated in Telerivet
#       * Read-only
#   
#   - project_id
#       * ID of the project this contact/service state belongs to
#       * Read-only
#
class ContactServiceState < Entity
    #
    # Saves the state id and any custom variables for this contact. If the state id is null, this
    # is equivalent to calling reset().
    #
    def save()
        super
    end

    #
    # Resets the state for this contact for this service.
    #
    def reset()
        @api.do_request("DELETE", get_base_api_path())
    end

    def id
        get('id')
    end

    def id=(value)
        set('id', value)
    end

    def contact_id
        get('contact_id')
    end

    def service_id
        get('service_id')
    end

    def time_created
        get('time_created')
    end

    def time_updated
        get('time_updated')
    end

    def project_id
        get('project_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/services/#{get('service_id')}/states/#{get('contact_id')}"
    end
 
end

end
