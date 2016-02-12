#! /usr/bin/env ruby
# encoding: UTF-8

original = ARGF.readlines.join

print "<div class='epigraph'>#{original}</div>"