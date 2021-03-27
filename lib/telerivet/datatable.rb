
module Telerivet

#
# Represents a custom data table that can store arbitrary rows.
# 
# For example, poll services use data tables to store a row for each response.
# 
# DataTables are schemaless -- each row simply stores custom variables. Each
# variable name is equivalent to a different "column" of the data table.
# Telerivet refers to these variables/columns as "fields", and automatically
# creates a new field for each variable name used in a row of the table.
# 
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the data table
#       * Read-only
#   
#   - name
#       * Name of the data table
#       * Updatable via API
#   
#   - num_rows (int)
#       * Number of rows in the table. For performance reasons, this number may sometimes be
#           out-of-date.
#       * Read-only
#   
#   - show_add_row (bool)
#       * Whether to allow adding or importing rows via the web app
#       * Updatable via API
#   
#   - show_stats (bool)
#       * Whether to show row statistics in the web app
#       * Updatable via API
#   
#   - show_contact_columns (bool)
#       * Whether to show 'Contact Name' and 'Phone Number' columns in the web app
#       * Updatable via API
#   
#   - vars (Hash)
#       * Custom variables stored for this data table
#       * Updatable via API
#   
#   - project_id
#       * ID of the project this data table belongs to
#       * Read-only
#
class DataTable < Entity
    #
    # Queries rows in this data table.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - time_created (UNIX timestamp)
    #         * Filter data rows by the time they were created
    #         * Allowed modifiers: time_created[ne], time_created[min], time_created[max]
    #     
    #     - contact_id
    #         * Filter data rows associated with a particular contact
    #     
    #     - vars (Hash)
    #         * Filter data rows by value of a custom variable (e.g. vars[q1], vars[foo], etc.)
    #         * Allowed modifiers: vars[foo][ne], vars[foo][prefix], vars[foo][not_prefix],
    #             vars[foo][gte], vars[foo][gt], vars[foo][lt], vars[foo][lte], vars[foo][min],
    #             vars[foo][max], vars[foo][exists]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default
    #         * Default: default
    #     
    #     - sort_dir
    #         * Sort the results in ascending or descending order
    #         * Allowed values: asc, desc
    #         * Default: asc
    #     
    #     - page_size (int)
    #         * Number of results returned per page (max 500)
    #         * Default: 50
    #     
    #     - offset (int)
    #         * Number of items to skip from beginning of result set
    #         * Default: 0
    #   
    # Returns:
    #     Telerivet::APICursor (of Telerivet::DataRow)
    #
    def query_rows(options = nil)
        require_relative 'datarow'
        @api.cursor(DataRow, get_base_api_path() + "/rows", options)
    end

    #
    # Adds a new row to this data table.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - contact_id
    #         * ID of the contact that this row is associated with (if applicable)
    #     
    #     - from_number (string)
    #         * Phone number that this row is associated with (if applicable)
    #     
    #     - vars
    #         * Custom variables and values to set for this data row
    #   
    # Returns:
    #     Telerivet::DataRow
    #
    def create_row(options = nil)
        require_relative 'datarow'
        DataRow.new(@api, @api.do_request("POST", get_base_api_path() + "/rows", options))
    end

    #
    # Retrieves the row in the given table with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the row
    #       * Required
    #   
    # Returns:
    #     Telerivet::DataRow
    #
    def get_row_by_id(id)
        require_relative 'datarow'
        DataRow.new(@api, @api.do_request("GET", get_base_api_path() + "/rows/#{id}"))
    end

    #
    # Initializes the row in the given table with the given ID, without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the row
    #       * Required
    #   
    # Returns:
    #     Telerivet::DataRow
    #
    def init_row_by_id(id)
        require_relative 'datarow'
        return DataRow.new(@api, {'project_id' => self.project_id, 'table_id' => self.id, 'id' => id}, false)
    end

    #
    # Gets a list of all fields (columns) defined for this data table. The return value is an
    # array of objects with the properties 'name', 'variable', 'type', 'order', 'readonly', and
    # 'lookup_key'. (Fields are automatically created any time a DataRow's 'vars' property is
    # updated.)
    # 
    # Returns:
    #     array
    #
    def get_fields()
        return @api.do_request("GET", get_base_api_path() + "/fields")
    end

    #
    # Allows customizing how a field (column) is displayed in the Telerivet web app.
    # 
    # Arguments:
    #   - variable
    #       * The variable name of the field to create or update.
    #       * Required
    #   
    #   - options (Hash)
    #     
    #     - name (string, max 64 characters)
    #         * Display name for the field
    #     
    #     - type (string)
    #         * Field type
    #         * Allowed values: text, long_text, number, boolean, email, url, audio, phone_number,
    #             date, date_time, groups, route, select, buttons, contact
    #     
    #     - order (int)
    #         * Order in which to display the field
    #     
    #     - readonly (bool)
    #         * Set to true to prevent editing the field in the Telerivet web app
    #   
    # Returns:
    #     object
    #
    def set_field_metadata(variable, options = nil)
        return @api.do_request("POST", get_base_api_path() + "/fields/#{variable}", options)
    end

    #
    # Returns the number of rows for each value of a given variable. This can be used to get the
    # total number of responses for each choice in a poll, without making a separate query for
    # each response choice. The return value is an object mapping values to row counts, e.g.
    # `{"yes":7,"no":3}`
    # 
    # Arguments:
    #   - variable
    #       * Variable of field to count by.
    #       * Required
    #   
    # Returns:
    #     object
    #
    def count_rows_by_value(variable)
        return @api.do_request("GET", get_base_api_path() + "/count_rows_by_value", {'variable' => variable})
    end

    #
    # Saves any fields that have changed for this data table.
    #
    def save()
        super
    end

    #
    # Permanently deletes the given data table, including all its rows
    #
    def delete()
        @api.do_request("DELETE", get_base_api_path())
    end

    def id
        get('id')
    end

    def name
        get('name')
    end

    def name=(value)
        set('name', value)
    end

    def num_rows
        get('num_rows')
    end

    def show_add_row
        get('show_add_row')
    end

    def show_add_row=(value)
        set('show_add_row', value)
    end

    def show_stats
        get('show_stats')
    end

    def show_stats=(value)
        set('show_stats', value)
    end

    def show_contact_columns
        get('show_contact_columns')
    end

    def show_contact_columns=(value)
        set('show_contact_columns', value)
    end

    def project_id
        get('project_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/tables/#{get('id')}"
    end
 
end

end
