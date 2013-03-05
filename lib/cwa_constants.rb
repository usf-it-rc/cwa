# Simply adding accessors to make the CWA plugin options available globally
# throughout the classes and modules of the plugin
class CwaConstants
  # Various regex for field validation
  USER_REGEX = /^[a-zA-Z0-9-]{3,20}$/
  GROUP_REGEX = /^[a-zA-Z0-9-\._]{3,20}$/
  PASSWD_REGEX = /[0-9A-Za-z\!@#\$%\^&\(\)-_=\+|\[\]\{\};:\/\?\.\>\<]{8,}$/
  JOBNAME_REGEX = /^[a-zA-Z0-9-_\.]{1,128}$/
  JOBPATH_REGEX = /^[\/a-zA-Z0-9-_\.]{1,4096}$/
  # number of groups that can be associated to a single user
  GROUP_MAX = 5
end
