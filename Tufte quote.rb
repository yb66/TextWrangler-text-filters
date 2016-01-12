#! /usr/bin/env ruby
# encoding: UTF-8

require 'uri'
require 'time'

lines = ARGF.readlines

quote_lines,rest = lines.partition{|line| line.start_with?( ">" ) }
href,rest =
  rest.partition{|line|
    if line.ascii_only? && URI.regexp =~ line
      begin
        URI(line) # if it's a valid URI
        true      # it will reach here
      rescue URI::InvalidURIError => e
        false # if not, return false
      end
    else
      false
    end
  }
footer,cite,date = *rest

href = href.empty? ?
  nil :
  href.first

if (date.nil? || date.empty?) &! cite.nil?
  begin
    time = Time.parse cite
    # will fail here if cite is not a date
    # and the following 2 lines won't be run
    date = cite
    cite = nil
  rescue ArgumentError => e
    # do nothing
  end
end

# To make sure
cite.force_encoding("ASCII-8BIT") unless cite.nil?
footer.force_encoding("ASCII-8BIT") unless footer.nil?

quote_lines.map!{|line| line.force_encoding("ASCII-8BIT") }
           .map!{|line| line.sub /^\>\s*/, "" }
quote = 
  quote_lines.inject([[]]){|mem,line|
                              if line !~ /^\s*$/
                                mem.last.push(line)
                                mem
                              else
                                mem.push([])
                              end
                          }.reject{|para| para.empty? }
                          .map{|para| para.join(" ").gsub(/\s+/, " ") }
                          .map{|para| "<p>#{para}</p>" }
                          .join

if cite || href
  cite = %Q!<cite>#{cite}</cite>!.gsub(%Q!\n!,'') unless cite.nil? || cite.empty?
  cite_class =  %Q! cite="#{href}"!.gsub(%Q!\n!,'') if href
  if href
    footer_text = %Q!<a href="#{href}">#{[footer,cite,date].reject{|x| x.nil? || x.empty?}.join(', ')}</a>!.gsub(%Q!\n!,'')
  else
    footer_text = "#{footer}#{cite}#{date}"
  end
else
  footer_text = %Q!#{[footer,date].reject{|x| x.nil? || x.empty?}.join(', ').gsub(%Q!\n!,'')}!
end


print <<TEMPLATE
<blockquote#{cite_class}>#{quote}<footer>#{footer_text}</footer>
</blockquote>
TEMPLATE