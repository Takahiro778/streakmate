module GoalsHelper
  def task_completed?(task)
    if task.respond_to?(:completed)        then !!task.completed
    elsif task.respond_to?(:done)          then !!task.done
    elsif task.respond_to?(:is_done)       then !!task.is_done
    elsif task.respond_to?(:checked)       then !!task.checked
    elsif task.respond_to?(:finished)      then !!task.finished
    elsif task.respond_to?(:completed_at)  then task.completed_at.present?
    elsif task.respond_to?(:done_at)       then task.done_at.present?
    elsif task.respond_to?(:finished_at)   then task.finished_at.present?
    elsif task.respond_to?(:status)        then %w[done completed finished].include?(task.status.to_s)
    else false
    end
  end
end
