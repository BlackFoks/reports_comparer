# coding: utf-8

class TxtReport
  attr_reader :filename
  
  def initialize(filename)
    @filename = filename
  end
end

class ReportComparer
  def compare_dirs(old_dir, new_dir)
    old_reps, new_reps = [], []
    
    # get list of old reports
    Dir.chdir(old_dir)
    old_reps = Dir.glob('*.*')
    
    # get list of new reposts
    Dir.chdir(new_dir)
    new_reps = Dir.glob('*.*')
    
    old_reps.each {|r| puts r }
    new_reps.each {|r| puts r }
    
  end

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

    # diff counter
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
          wputs "============== Различие #{count} ==============="
          puts "<<<======================"
          puts diff[:old].encode('cp866', 'cp1251')
          puts "========================="
          puts diff[:new].encode('cp866', 'cp1251')
          puts "======================>>>"
        end
      end
    end
    
    wputs "\nВсего найдено различий: #{count}"
  end
end

# checks arg for short or full flag
def check(arg, s, f)
  arg == "-#{s}" || arg == "--#{f}"
end

# puts string in cp866 encoding
def wputs(str)
  begin
    puts str.encode('cp866')
  rescue
    puts str
  end
end

# print help
if ARGV.empty? || ARGV.count < 2
  wputs "Скрипт сравнения отчетов."
  wputs "Использование: ruby rep_comparer.rb [опции] [старый_отчет] [новый_отчет]"
  puts
  wputs "Ищет отличия, кроме отличий в датах.\n\n"
  wputs "Строки, в которых присутствуют даты формата 12.07.11 15:35"
  wputs "или формата 12.07.2011 15:35 или формата 12/07/11 не будут"
  wputs "учитываться при сравнении."
  puts
  wputs "Доступные опции:"
  wputs " --all (-a): в процессе сравнения будут учитываться любые"
  wputs "             отличия, в том числе и отличия в датах и времени."
  
  exit
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
# rc.compare old_txt, new_txt, match_all
rc.compare_dirs ARGV[-2], ARGV[-1]