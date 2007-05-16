#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


class BuildStatus
  def initialize artifacts_directory
    @artifacts_directory = artifacts_directory 
  end


  def to_s
    read_latest_status.to_s
  end


  def status_file
    return Dir[ "#{ @artifacts_directory }/build_status.*" ].first
  end


  def incomplete?
    read_latest_status == 'incomplete'
  end


  def match_elapsed_time file_name
    match =  /^build_status\.[^\.]+\.in(\d+)s$/.match( file_name )
    if !match or !$1
      raise 'Could not parse elapsed time.'
    end
    return $1.to_i
  end


  def never_built?
    read_latest_status == 'never_built'
  end


  def succeeded?
    read_latest_status == 'success'
  end


  def succeed! elapsed_time
    remove_status_file
    touch_status_file "success.in#{ elapsed_time }s"
  end


  def failed?
    read_latest_status == 'failed'
  end


  def fail! elapsed_time, error_message=nil
    remove_status_file
    touch_status_file "failed.in#{ elapsed_time }s", error_message
  end

  
  def created_at
    if file = status_file
      File.mtime file
    end
  end


  def timestamp
    build_dir_mtime = File.mtime( @artifacts_directory )
    begin
      build_log_mtime = File.mtime( "#{ @artifacts_directory }/build.log" )
    rescue
      return build_dir_mtime
    end      
    build_log_mtime > build_dir_mtime ? build_log_mtime : build_dir_mtime
  end


  def elapsed_time
    file = status_file
    match_elapsed_time File.basename( file )
  end


  def elapsed_time_in_progress
    incomplete? ? ( Time.now - created_at ).ceil : nil
  end


  private


  def touch_status_file status, error_message=nil
    filename = "#{ @artifacts_directory }/build_status.#{ status }"
    FileUtils.touch filename
    if error_message
      File.open( filename, "w" ) do |f|
        f.write error_message
      end
    end
  end


  def remove_status_file
    FileUtils.rm_f Dir[ "#{ @artifacts_directory }/build_status.*" ]
  end

  
  def read_latest_status
    file = status_file
    file ? match_status( File.basename( file ) ).downcase : 'never_built'
  end


  def match_status file_name
    /^build_status\.([^\.]+)(\..+)?/.match( file_name )[ 1 ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
