# Simple locks for local fs.

require 'fileutils'

class FileLock
  def self.acquire?(name)
    tmpname = "/tmp/file_lock.#{rand(10000)}"
    FileUtils.touch tmpname
    return File.link tmpname, name rescue nil
  ensure
    File.unlink tmpname
  end

  def self.release(name)
    File.unlink name
  end
end
