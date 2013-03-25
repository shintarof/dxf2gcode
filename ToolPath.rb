#!/usr/bin/ruby
require 'optparse'
require 'rubygems'
require 'yaml'
require 'pp'

class ToolPath
    attr_accessor :dxf_config
    def initialize
        @dxf_config = YAML.load(File.read("./config/dxf.yml"))
    end

    def generatepath(type)
        file=File.readlines(ARGV[0])
        if file.index(type)
            start=file.index(type)
            path=[]
            tool=[]
            path.push(type)
            j=0
            for i in start..file.size-1
                 p i.to_s+"::"+j.to_s+ "::"+@dxf_config["SHAPE"][type.strip][j].to_s+"==="+file[i].strip  
                next if @dxf_config["SHAPE"][type.strip][j]!=file[i].strip  
                j= j>=@dxf_config["SHAPE"][type.strip].size-1 ? 0: j+=1
                tool.push(file[i+1].strip.to_i.round(2))
                if tool.size==@dxf_config["SHAPE"][type.strip].size
                    path.push(tool) 
                    tool=[]
                end
            end
        end 
        return path
    end
end

