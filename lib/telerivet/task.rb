
module Telerivet

#
# Represents an asynchronous task that is applied to all entities matching a filter.
# 
# Tasks include services applied to contacts, messages, or data rows; adding
# or removing contacts from a group; blocking or unblocking sending messages to a contact;
# updating a custom variable; deleting contacts, messages, or data rows; or
# exporting data to CSV.
# 
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the task
#       * Read-only
#   
#   - task_type (string)
#       * The task type
#       * Read-only
#   
#   - task_params (Hash)
#       * Parameters applied to all matching rows (specific to `task_type`). See
#           [project.createTask](#Project.createTask).
#       * Read-only
#   
#   - filter_type
#       * Type of filter defining the rows that the task is applied to
#       * Read-only
#   
#   - filter_params (Hash)
#       * Parameters defining the rows that the task is applied to (specific to
#           `filter_type`). See [project.createTask](#Project.createTask).
#       * Read-only
#   
#   - time_created (UNIX timestamp)
#       * Time the task was created in Telerivet
#       * Read-only
#   
#   - time_active (UNIX timestamp)
#       * Time Telerivet started executing the task
#       * Read-only
#   
#   - time_complete (UNIX timestamp)
#       * Time Telerivet finished executing the task
#       * Read-only
#   
#   - total_rows (int)
#       * The total number of rows matching the filter (null if not known)
#       * Read-only
#   
#   - current_row (int)
#       * The number of rows that have been processed so far
#       * Read-only
#   
#   - status (string)
#       * The current status of the task
#       * Allowed values: created, queued, active, complete, failed, cancelled
#       * Read-only
#   
#   - vars (Hash)
#       * Custom variables stored for this task
#       * Read-only
#   
#   - table_id (string, max 34 characters)
#       * ID of the data table this task is applied to (if applicable)
#       * Read-only
#   
#   - user_id (string, max 34 characters)
#       * ID of the Telerivet user who created the task (if applicable)
#       * Read-only
#   
#   - project_id
#       * ID of the project this task belongs to
#       * Read-only
#
class Task < Entity
    #
    # Cancels a task that is not yet complete.
    # 
    # Returns:
    #     Telerivet::Task
    #
    def cancel()
        require_relative 'task'
        Task.new(@api, @api.do_request("POST", get_base_api_path() + "/cancel"))
    end

    def id
        get('id')
    end

    def task_type
        get('task_type')
    end

    def task_params
        get('task_params')
    end

    def filter_type
        get('filter_type')
    end

    def filter_params
        get('filter_params')
    end

    def time_created
        get('time_created')
    end

    def time_active
        get('time_active')
    end

    def time_complete
        get('time_complete')
    end

    def total_rows
        get('total_rows')
    end

    def current_row
        get('current_row')
    end

    def status
        get('status')
    end

    def table_id
        get('table_id')
    end

    def user_id
        get('user_id')
    end

    def project_id
        get('project_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/tasks/#{get('id')}"
    end
 
end

end
