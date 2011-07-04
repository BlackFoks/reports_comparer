# coding: utf-8

class TxtReport
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end  
end

class ReportComparer
  def compare(oldTxt, newTxt, match_all = false)
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

    count = 0
    
    # show diff
    diffs.each do |diff|
      if diff[:old] || diff[:new]
        if !match_all &&
          # date like 12.07.2011 13:45
          (/^.*\d+\.\d+\.\d+\s\d+:\d+.*$/ =~ diff[:old].encode('utf-8') || 
           /^.*\d+\.\d+\.\d+\s\d+:\d+.*$/ =~ diff[:new].encode('utf-8') ||
          # date like 12/07/11
           /^.*\d{1,2}\/\d{1,2}\/\d{1,2}.*$/ =~ diff[:old].encode('utf-8') || 
           /^.*\d{1,2}\/\d{1,2}\/\d{1,2}.*$/ =~ diff[:new].encode('utf-8'))
        else
          count += 1
          puts "============== Различие #{count} ===============".encode('cp866')
          puts "<<<======================"
          puts diff[:old].encode('cp866', 'cp1251')
          puts "========================="
          puts diff[:new].encode('cp866', 'cp1251')
          puts "======================>>>"
        end
      end      
    end
    
    puts "\nВсего найдено различий: #{count}".encode('cp866')
    
  end
end

# checks arg for short or full flag
def check(arg, s, f)
  arg == "-#{s}" || arg == "--#{f}"
end

# open files
old_txt = TxtReport.new(ARGV[-2])
new_txt = TxtReport.new(ARGV[-1])

# set default options
match_all = false

# check user input for options
ARGV.each do |arg|
  match_all ||= check arg, :a, :all
end

# compare
rc = ReportComparer.new
rc.compare old_txt, new_txt, match_all