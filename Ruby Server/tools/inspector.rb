require 'colorize'
require '../scripts/binary'

TYPES = [:normal, :warning, :error]
ARGS = Hash[ARGV.flat_map { |s| s.scan(/--?([^=\s]+)(?:=(\S+))?/) }]

Line = Struct.new(:type, :message)

def load_lines(filename)
  lines = []
  reader = BinaryReader.new(IO.read(filename, mode: 'rb'))
  while reader.can_read?
    line = Line.new(TYPES[reader.read(:byte)], reader.read(:string))
    lines << line
  end
  lines
end

if ARGS.key?('today')
  filename = "../data/logs/#{Time.new.strftime('%F')}.dat"
  lines = load_lines(filename)

  # Filtra as mensagens que serão exibidas.
  if ARGS.key?('type')
    puts "\n"
    lines.each { |l| puts "Message: #{l.message}\n" if l.type == ARGS['type'].to_sym }
  end
  puts "\n"
end