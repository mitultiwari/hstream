class Login < ActiveRecord::Base
  def merge_shortlist(s)
    self[:shortlist] = (shortlist.split(',')+s.split(',')).uniq.join(',')
    save
  end

  def self.create_or_merge(email, shortlist)
    user = find_by_email(email)
    if user
      user.merge_shortlist(shortlist)
    else
      user = Login.create(:email => email, :shortlist => shortlist)
    end
    user
  end
end
