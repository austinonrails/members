require 'net/http'

# Adds Akismet functionality to Rails...set your Wordpress API key and "blog" name
# in environment.rb:
#
# Akismet.key = "fdfsfdjkfljdf"
# Akismet.blog = "members.austinonrails.org"
#
# You can also set a logger, e.g.:
# Akismet.logger = ActiveRecord::Base.logger
#
# To verify content as non-spam, call
# Akismet.comment_check with an ActionController-wrapped request, and a comment hash with the following format:
#   comment => {:type => description of the content, can be anything,
#               :author => the name of the person submitting content,
#               :url => the url of the person submitting content,
#               :body => the submitted content
#               }
#
#  Created by Robert Rasmussen on 2006-10-09.
#  Copyright (c) 2006. All rights reserved.
#

class Akismet
  cattr_accessor :key, :blog, :logger
  @@verified = nil
  
  def self.comment_check(request, comment)
    @@verified ||= verify_key

    if @@verified
      post_form("http://#{key}.rest.akismet.com/1.1/comment-check",
                                     {"blog" => blog,
                                      "user_ip" => request.remote_ip,
                                      "user_agent" => request.cgi.HTTP_USER_AGENT,
                                      "referrer" => request.cgi.HTTP_REFERRER,
                                      "comment_type" => comment[:type],
                                      "comment_author" => comment[:author],
                                      "comment_author_email" => comment[:email],
                                      "comment_author_url" => comment[:url],
                                      "comment_content" => comment[:body]}).body == "false" rescue true
    else
      logger.error("Akismet key was not verified, cannot filter comments!") if logger
      true
    end
  end
  
  private
  
  def self.verify_key
    response = post_form("http://rest.akismet.com/1.1/verify-key", {"key" => key, "blog" => blog})
    @@verified = (response.body == "valid")
  end
  
  def self.post_form(uri, data)
    u = URI.parse uri
    http = Net::HTTP.new(u.host, u.port)
    http.post(u.path, data.collect{|k,v|"#{k}=#{v}"}.join("&"))
  end
end
