# Getting around http://help.papertrailapp.com/discussions/problems/11-rails-logtailer-issues
module Rails
  class Server
    def log_path
      Rails.paths.log.first.to_s
    end
  end
end
