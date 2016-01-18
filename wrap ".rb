#! /usr/bin/env ruby
# encoding: UTF-8

original = ARGF.readlines.join

print case original
  when /^"'([[:print:]]*)'"$/ then %Q!'"#{$1}"'!
  when /^'"([[:print:]]*)"'$/ then %Q!{#{$1}}!
  when /^\{([[:print:]]*)\}/ then %Q!\#{#{$1}}!
  when /^#\{([[:print:]]*)\}/ then $1
  when /^"(?!')([[:print:]]*)(?<!')"$/ then %Q!'#{$1}'!
  else %Q!"#{original}"!
end