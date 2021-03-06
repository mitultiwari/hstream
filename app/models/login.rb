class Login < ActiveRecord::Base
  belongs_to :email

  def merge_shortlist(s)
    self[:shortlist] = (shortlist.split(',')+s.split(',')).uniq.join(',')
    save
  end

  def add_shortlist(id)
    self[:shortlist] = (shortlist.split(',')+[id]).uniq.join(',')
    save
  end

  def del_shortlist(id)
    self[:shortlist] = (shortlist.split(',').uniq-[id]).join(',')
    save
  end

  def has_followees?
    !shortlist.blank?
  end

  def followee_count
    shortlist.split(',').size rescue 0
  end

  def self.create_or_merge(email, shortlist)
    email = Email.find_or_create_by_email(email.downcase)
    user = find_by_email_id(email.id)
    if user
      user.merge_shortlist(shortlist)
    else
      user = Login.create(:email => email, :shortlist => shortlist)
    end
    user
  end

  # given a scope of items, return a scope of followed items
  def stream(scope)
    reload
    s = shortlist.split(',')
    t = Item.arel_table
    scope.where(t[:author].in(s).
             or(t[:story_hnid].in(s)).
             or(t[:hnid].in(s)))
  end

end
