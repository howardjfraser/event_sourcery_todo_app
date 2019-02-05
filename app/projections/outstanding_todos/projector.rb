module EventSourceryTodoApp
  module Projections
    module OutstandingTodos
      class Projector
        include EventSourcery::Postgres::Projector

        projector_name :outstanding_todos

        # Database tables that form the projection.

        table :query_outstanding_todos do
          column :todo_id, 'UUID NOT NULL'
          column :title, :text
          column :description, :text
          column :due_date, DateTime
          column :stakeholder_email, :text
          column :overview, :text
        end

        # Event handlers that update the projection in response to different events
        # from the store.

        project TodoAdded do |event|
          table.insert(
            todo_id: event.aggregate_id,
            title: event.body['title'],
            description: event.body['description'],
            due_date: event.body['due_date'],
            stakeholder_email: event.body['stakeholder_email'],
            overview: event.body['overview']
          )
        end

        project TodoAmended do |event|
          table.where(
            todo_id: event.aggregate_id,
          ).update(
            event.body.slice('title', 'description', 'due_date', 'stakeholder_email', 'overview')
          )
        end

        project TodoCompleted, TodoAbandoned do |event|
          table.where(todo_id: event.aggregate_id).delete
        end
      end
    end
  end
end
