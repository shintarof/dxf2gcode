#!/usr/bin/ruby
require 'optparse'
require 'rubygems'
require 'yaml'
require 'pp'

class GcodeTool
    def initialize
        @f=open(ARGV[0].gsub(/.dxf/,".ngc"),"a")
        @cnc_config = YAML.load(File.read("./config/cnc.yml"))
    end

    def gcode_init()
        @f.print "G90\n"  # absolute positioning
        @f.print "F"+@cnc_config["feed"].to_s+"\n"  # feed rate
        @f.print "S"+@cnc_config["spindle"].to_s+"\n"  # spindle speed
        p "S"+@cnc_config["spindle"].to_s+"\n"  # spindle speed
        @f.print "T"+@cnc_config["tool"].to_s+"\n"  # tool
        @f.print "M08\n"  # coolant on
        @f.print "M03\n"  # spindle on clockwise
    end

    def gcode_end()
        @f.print "M05\n"  # spindle stop
        @f.print "M09\n"  # coolant off
        @f.print "M30\n"  # program end and reset
        return @f.path
    end

    def generatecode(data_arr)
        x_old=0
        y_old=0
        if !data_arr.nil?
            type=data_arr[0].strip
            p "-==="+type.to_s+"===-"
            data_arr.each_with_index do |data,index|
                case type 
                when "CIRCLE" 
                    if index == 0
                       @f.print "G00X#{data_arr[1][0]}Y#{data_arr[1][1]}Z#{@cnc_config["z_max"]}\n" 
                    else
                        # rapid motion
                       @f.print "G0 Z#{@cnc_config["z_min"]}\n" 
                       @f.print "G0 X#{data[0]}Y#{data[1]}\n"
                       @f.print "G03 X#{data[0]}Y#{data[1]}I#{data[2]}J-0.00\n" if data[2]!=0
                       @f.print "G0 Z#{@cnc_config["z_max"]}\n" 
                    end
                when "ARC"
                    p "none"
                when "LINE"
                @f.print ";LINE\n"
                    if index==0
                       @f.print "G00X#{data_arr[1][0]}Y#{data_arr[1][1]}Z#{@cnc_config["z_max"]}\n"
                    else 

                        p "G01 X#{data[0]}Y#{data[1]}\n" 
                        p "G01 Z#{@cnc_config["z_min"]}\n" 
                        p "G01 X#{data[2]}Y#{data[3]}\n" 
                        p "G01 Z#{@cnc_config["z_max"]}\n" 


                        # rapid motion
                       @f.print "G01 X#{data[0]}Y#{data[1]}\n" 
                       @f.print "G01 Z#{@cnc_config["z_min"]}\n" 
                       @f.print "G01 X#{data[2]}Y#{data[3]}\n" 
                       @f.print "G01 Z#{@cnc_config["z_max"]}\n" 
                    end

                when "LWPOLYLINE"
                    if index==0
                       @f.print "G00X#{data_arr[1][1]}Y#{data_arr[1][2]}Z#{@cnc_config["z_max"]}\n"
                    else 
                        # rapid motion
                       @f.print "X#{data[1]}Y#{data[2]}\n" 
                       @f.print "Z#{@cnc_config["z_min"]}\n" 
                       @f.print "X#{data[3]}Y#{data[4]}\n" 
                       @f.print "Z#{@cnc_config["z_max"]}\n" 
                    end

                when "POLYLINE"
                    if index==0
                       @f.print "G00X#{data_arr[1][1]}Y#{data_arr[1][2]}Z#{@cnc_config["z_max"]}\n"
                    else 
                        # rapid motion
                       @f.print "X#{x_old}Y#{y_old}\n" 
                       @f.print "Z#{@cnc_config["z_min"]}\n" 
                       @f.print "X#{data[1]}Y#{data[2]}\n" 
                       @f.print "Z#{@cnc_config["z_max"]}\n" 
                        x_old=data[1]
                        y_old=data[2] 
                    end
                else

                end
            end
        end
    end
end

