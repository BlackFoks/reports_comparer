# coding: utf-8

class TxtReport
  attr_reader :filename
  
  def initialize(filename)
    @filename = filename
  end
end

class ReportComparer
  def initialize
    @summary = []
  end
  def compare_dirs(old_dir, new_dir, match_all = false)
    old_reps, new_reps = [], []
    
    # get list of old reports
    Dir.chdir(old_dir)
    old_reps = Dir.glob('*.txt')
    
    # get list of new reposts
    Dir.chdir(new_dir)
    new_reps = Dir.glob('*.txt')
    
    # get list of reps
    old_new_reps = old_reps & new_reps
    only_old_reps = old_reps - new_reps
    only_new_reps = new_reps - old_reps
    
    wputs "Присутствуют только в папке со старыми отчетами:"
    only_old_reps.each {|r| wputs ' '*4 + r }
    wputs "Всего: #{only_old_reps.count}"
    
    wputs "\nПрисутствуют только в папке с новыми отчетами:"
    only_new_reps.each {|r| wputs ' '*4 + r }
    wputs "Всего: #{only_new_reps.count}"
    
    wputs "\nОбщих отчетов:"
    old_new_reps.each {|r| wputs ' '*4 + r }
    wputs "Всего: #{old_new_reps.count}\n\n"
    
    #compare files...
    old_new_reps.each do |r|
      old_filename = File.join(old_dir, r)
      new_filename = File.join(new_dir, r)
      old_txt_rep = TxtReport.new(old_filename)
      new_txt_rep = TxtReport.new(new_filename)
      self.compare(old_txt_rep, new_txt_rep, match_all)
      wputs "\n\n"
    end
    
    wputs "Итоговая информация:"
    @summary.each do |sum|
      if sum[:count] > 0
        wputs "#{sum[:file]} => ошибок: #{sum[:count]}"
      else
        wputs "#{sum[:file]} => Ok!"
      end
    end
  end

  def compare(oldTxt, newTxt, match_all = false)
    wputs "Сравниваем файлы #{oldTxt.filename} и #{newTxt.filename}..."
  
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
      if diff[:old] && diff[:new]
        if !match_all &&
          (/^.*ОТЧЕТ ПОЛУЧЕН.*$/ =~ diff[:old].encode('utf-8', 'cp1251') ||
           /^.*ОТЧЁТ ПОЛУЧЕН.*$/ =~ diff[:old].encode('utf-8', 'cp1251') ||
           /^.*Отчёт получен.*$/ =~ diff[:old].encode('utf-8', 'cp1251') ||
           /^.*Отчет получен.*$/ =~ diff[:old].encode('utf-8', 'cp1251') ||
           /^.*Отчет выполнен.*$/ =~ diff[:old].encode('utf-8', 'cp1251') ||
           /^.*Отчёт выполнен.*$/ =~ diff[:old].encode('utf-8', 'cp1251'))
        else
          count += 1
          wputs "============== Различие #{count} ==============="
          wputs "<<<======================"
          wputs diff[:old].encode('cp866', 'cp1251')
          wputs "========================="
          wputs diff[:new].encode('cp866', 'cp1251')
          wputs "======================>>>"
        end
      end
    end
    
    @summary << { :file => oldTxt.filename, :count => count }
    wputs "\nВсего найдено различий: #{count}"
  end
end

# checks arg for short or full flag
def check(arg, s, f)
  arg == "-#{s}" || arg == "--#{f}"
end

# puts string
def wputs(str='')
  begin
    if $save_to_file
      $out_file.puts(str.encode('utf-8'))
    else
      puts str.encode('cp866')
    end
  rescue
    if $save_to_file
      $out_file.puts(str)
    else
      puts str
    end
  end
end

# print help
if ARGV.empty? || ARGV.count < 2
  wputs "Скрипт сравнения отчетов."
  wputs "Использование: ruby rep_comparer.rb [опции] [старый_отчет] [новый_отчет]"
  wputs
  wputs "Ищет отличия, кроме отличий в датах.\n\n"
  wputs "Строки, в которых присутствуют даты формата 12.07.11 15:35"
  wputs "или формата 12.07.2011 15:35 или формата 12/07/11 не будут"
  wputs "учитываться при сравнении."
  wputs
  wputs "Доступные опции:"
  wputs " --all (-a) : в процессе сравнения будут учитываться любые"
  wputs "              отличия, в том числе и отличия в датах и времени."
  wputs " --dirs (-d): сравниваться будут все файлы внутри указанных"
  wputs "              директорий."
  wputs " --file (-f): вывод будет осуществлен в файл в папке скрипта"
  wputs "              в кодировке cp1251."
  wputs
  exit
end

# open files
old_txt = TxtReport.new(ARGV[-2])
new_txt = TxtReport.new(ARGV[-1])

# set default options
match_all = false
match_dirs = false
$save_to_file = false

# check user input for options
ARGV.each do |arg|
  match_all    ||= check arg, :a, :all
  match_dirs   ||= check arg, :d, :dirs
 $save_to_file ||= check arg, :f, :file
end

# open file if we should write to file
if $save_to_file
  rep_filename = 'report_' + Time.now.strftime('%Y_%m_%d_%H_%M_%S') + '.txt'
  $out_file = File.open(rep_filename, 'w')
end

# compare
rc = ReportComparer.new
if match_dirs
  rc.compare_dirs ARGV[-2], ARGV[-1], match_all
else
  rc.compare old_txt, new_txt, match_all
end

# close file if it has been opened
$out_file.close if $save_to_file
