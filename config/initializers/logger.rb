require 'logger'
require 'file_lock'

# Don't raise errors if log is about to be rotated.
class Logger
  class LogDevice
    alias_method :old_shift_log_period_13413141341234, :shift_log_period
    def shift_log_period(now)
      lockfile = "#{Rails.root}/log/development.lock"
      return unless FileLock.acquire?(lockfile)
      begin
        age_file = "#{@filename}.#{previous_period_end(now).strftime("%Y%m%d")}"
        if FileTest.exist?(age_file)
          puts "'#{age_file}' already exists. Assuming rotation already occurred."
          return true
        end
        old_shift_log_period_13413141341234(now)
      ensure
        FileLock.release(lockfile)
      end
    end
  end
end
