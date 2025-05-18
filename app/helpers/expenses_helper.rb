module ExpensesHelper
  def expense_by_category
    @expense_by_category ||= CategoryServices::FetchExpensesByCategory.call(current_user.id)
  end
end
