class ActiveSupport::OrderedHash
  def top_keys(n=10)
    to_a.sort_by(&:second).reverse[0..n].collect(&:first)
  end
end
