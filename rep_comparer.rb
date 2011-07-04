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
    
    File.open(oldTxt.filename, 'r') do |old_file|
      old_file.lines.each do |line|
        #old_rep << { :n => old_file.lineno, :text => line }
        old_rep[old_file.lineno] = line
      end      
    end
    
    File.open(newTxt.filename, 'r') do |new_file|
      new_file.lines.each do |line|
        new_rep[new_file.lineno] = line
      end      
    end
    
    (0..new_rep.count).each do |i|
      if old_rep[i] && new_rep[i]
        if old_rep[i] != new_rep[i]
          diffs << { :old => old_rep[i], :new => new_rep[i] } 
        end
      else
        if !old_rep[i]
          diffs << { :old => nil, :new => new_rep[i] }
        end
        if !new_rep[i]
          diffs << { :old => old_rep[i], :new => nil }
        end
      end
    end

    diffs.each do |diff|
      if diff[:old] || diff[:new]
        if /^.*\d+\.\d+\.\d+\s\d+:\d+.*$/ =~ diff[:old].encode('utf-8') #||
           /^.*\d+\.\d+\.\d+\s\d+:\d+.*$/ =~ diff[:new].encode('utf-8')
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
    #puts diffs.inspect
  end
end

old_txt = TxtReport.new(ARGV[-2])
new_txt = TxtReport.new(ARGV[-1])

rc = ReportComparer.new
rc.compare old_txt, new_txt