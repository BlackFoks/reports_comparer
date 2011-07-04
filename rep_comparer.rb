﻿# coding: utf-8

class TxtReport
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end  
end

class ReportComparer
  def compare(oldTxt, newTxt)
    diffs = []
    old_rep = {}
    new_rep = {}
    
    # read old file
    File.open(oldTxt.filename, 'r') do |f|
      f.lines.each {|line| old_rep[f.lineno] = line }      
    end
    
    # read new file
    File.open(newTxt.filename, 'r') do |f|
      f.lines.each {|line| new_rep[f.lineno] = line }      
    end
    
    # compare
    (0..new_rep.count).each do |i|
      if old_rep[i] && new_rep[i]
        # if different
        diffs << { :old => old_rep[i], :new => new_rep[i] } if old_rep[i] != new_rep[i]
      else
        diffs << { :old => nil, :new => new_rep[i] } if !old_rep[i]
        diffs << { :old => old_rep[i], :new => nil } if !new_rep[i]
      end
    end

    # show diff
    diffs.each do |diff|
      if diff[:old] || diff[:new]
        if /^.*\d+\.\d+\.\d+\s\d+:\d+.*$/ =~ diff[:old].encode('utf-8') || # date like 12.07.2011 13:45
           /^.*\d+\.\d+\.\d+\s\d+:\d+.*$/ =~ diff[:new].encode('utf-8') ||
           /^.*\d{1,2}\/\d{1,2}\/\d{1,2}.*$/ =~ diff[:old].encode('utf-8') || # date like 12/07/11
           /^.*\d{1,2}\/\d{1,2}\/\d{1,2}.*$/ =~ diff[:new].encode('utf-8')
        else
          puts "============== Различие ===============".encode('cp866')
          puts "<<<======================"
          puts diff[:old].encode('cp866', 'cp1251')
          puts "========================="
          puts diff[:new].encode('cp866', 'cp1251')
          puts "======================>>>"
        end
      end      
    end
  end
end

old_txt = TxtReport.new(ARGV[-2])
new_txt = TxtReport.new(ARGV[-1])

rc = ReportComparer.new
rc.compare old_txt, new_txt