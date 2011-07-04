
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
        old_rep << { :n => old_file.lineno, :text => line }
      end      
    end
    
    File.open(oldTxt.filename, 'r') do |new_file|
      new_file.lines.each do |line|
        new_rep << { new_file.lineno => line }
      end      
    end
    
    (0..new_rep.count).each do |i|
      puts new_rep[i]
    end    
  end
end

old_txt = TxtReport.new(ARGV[-2])
new_txt = TxtReport.new(ARGV[-1])

rc = ReportComparer.new
rc.compare old_txt, new_txt