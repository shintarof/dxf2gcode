#!/usr/bin/ruby
require 'optparse'
require 'rubygems'
require 'yaml'
require 'pp'
require './GcodeTool.rb'
require './ToolPath.rb'
#require FILE.dirname(__FILE__)
abort("please choose dxf format file") unless ARGV[0].include?(".dxf")
tool=ToolPath.new
gcode=GcodeTool.new
gcode.gcode_init()
tool.dxf_config["SHAPE"].each do |type,config|
    pp type
    gcode.generatecode(tool.generatepath("#{type}\n"))
end
puts gcode.gcode_end()
