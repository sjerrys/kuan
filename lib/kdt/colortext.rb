# -*- coding: utf-8 -*-
#实现宽岛体－彩色文字功能
#用户输入任意文字，可转换成一定格式的指定彩色文字图片
#文字中需要标注彩色的部分，用#做为分隔符

require 'subexec'

class ColorText

  LINE_LENGTH = 14
  COLORS = %w[blue red green purple orange] 

  def initialize
    @ttf = File.join(File.dirname(File.expand_path(__FILE__)),'fzlt.ttf')
    @file_dir = %(#{Rails.root.to_s}/tmp/kdts/)
    Dir.mkdir(@file_dir) unless Dir.exist?(@file_dir)
    @filename_base = %(#{Process.pid}_)
    @color_stick = nil
    @logger ||= Logger.new("#{Rails.root.to_s}/log/demo_kdt.log")
  end

  def generate(str)
    require 'chinese/width'
    str = Width.instance.half2full str, ['#']
    line_count = 0
    files = wrap_lines(str).reduce([]) do |fs, line|
      line_count += 1
      fs << convert(line, line_count) unless line.blank?
      fs
    end
    montage files
  end

  def wrap_lines(str)
    str.lines.reduce([]) do |lines, l|
      l.chomp!
      sep_offsets = []
      l.chars.each_with_index {|c, i| sep_offsets << i if c == '#'}
      l.delete! '#'
      if l.length <= LINE_LENGTH
        sep_offsets.each {|i| l.insert i, '#'}
        lines << l
      else
        line_counter = ins_counter = ins_offset = 0
        l.scan(/.{1,#{LINE_LENGTH}}/) do |m|
          ins_offset = ins_counter
          sep_offsets.each do |i|
            start_pos = line_counter*LINE_LENGTH+ins_offset
            end_pos = start_pos + LINE_LENGTH + ins_counter - ins_offset
            if (start_pos...end_pos).cover? i
              m.insert i - line_counter*LINE_LENGTH - ins_offset, '#'
              ins_counter += 1 
            end
          end
          lines << m
          line_counter += 1
        end 
      end
      lines
    end
  end

  def convert(line, count)
    @logger.info line
    file = @file_dir + @filename_base + count.to_s + '.png'
    base_command = %(convert -size 500x100 xc:none -fill yellow -draw 'line 15,0 15,99' -undercolor white)
    color_flag = !@color_stick.nil?
    last_color = nil
    command = line.split('#').reduce(base_command) do |c, token|
      color = last_color = @color_stick || (color_flag ? COLORS.sample : "black")
      color_flag = !color_flag
      @color_stick = nil
      pointsize = color_flag ? "26" : "34"
      c += %( \\( -clone 0 -fill #{color} -font #{@ttf} -pointsize #{pointsize} -annotate +5+60 "#{token}" \\))
    end + %( -delete 0 -trim +repage +append -transparent yellow -trim +repage -background white -flatten #{file})
    @color_stick = (last_color == 'black') ? nil : last_color
    @color_stick = @color_stick.nil? ? COLORS.sample : nil if line.last == '#'
    @logger.info command
    run_command command
    file
  end

  def montage(files)
    m_file = @file_dir + @filename_base + "m.png"
    command = files.reduce("montage") do |c, file|
      c += %( -label '' #{file})
    end + %( -tile 1x -geometry '1x1+0+0<' #{m_file})
    run_command command
    files.each {|f| File.delete f}
    m_file
  end

  def run_command(command)
    sub = Subexec.run(command)
    if sub.exitstatus != 0
      raise Exception,"Command (#{command.inspect.gsub("\\", "")}) failed: #{{:status_code => sub.exitstatus, :output => sub.output}.inspect}"
    end
    sub.output
  end
end
