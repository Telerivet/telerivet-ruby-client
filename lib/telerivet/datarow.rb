
module Telerivet

#
# Represents a row in a custom data table.
# 
# For example, each response to a poll is stored as one row in a data table.
# If a poll has a question with ID 'q1', the verbatim response to that question would be
# stored in row.vars.q1, and the response code would be stored in row.vars.q1_code.
# 
# Each custom variable name within a data row corresponds to a different
# column/field of the data table.
# 
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the data row
#       * Read-only
#   
#   - contact_id
#       * ID of the contact this row is associated with (or null if not associated with any
#           contact)
#       * Updatable via API
#   
#   - from_number (string)
#       * Phone number that this row is associated with (or null if not associated with any
#           phone number)
#       * Updatable via API
#   
#   - vars (Hash)
#       * Custom variables stored for this data row
#       * Updatable via API
#   
#   - time_created (UNIX timestamp)
#       * The time this row was created in Telerivet
#       * Read-only
#   
#   - time_updated (UNIX timestamp)
#       * The time this row was last updated in Telerivet
#       * Read-only
#   
#   - table_id
#       * ID of the table this data row belongs to
#       * Read-only
#   
#   - project_id
#       * ID of the project this data row belongs to
#       * Read-only
#
class DataRow < Entity
    #
    # Saves any fields or custom variables that have changed for this data row.
    #
    def save()
        super
    end

    #
    # Deletes this data row.
    #
    def delete()
        @api.do_request("DELETE", get_base_api_path())
    end

    def id
        get('id')
    end

    def contact_id
        get('contact_id')
    end

    def contact_id=(value)
        set('contact_id', value)
    end

    def from_number
        get('from_number')
    end

    def from_number=(value)
        set('from_number', value)
    end

    def time_created
        get('time_created')
    end

    def time_updated
        get('time_updated')
    end

    def table_id
        get('table_id')
    end

    def project_id
        get('project_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/tables/#{get('table_id')}/rows/#{get('id')}"
    end
 
end

end
