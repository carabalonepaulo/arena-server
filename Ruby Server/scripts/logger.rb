class Logger
  HEADER = { :normal => 0, :warning => 1, :error => 2 }
  def initialize
    @date = Time.new.strftime('%F')
    @filename = "./data/logs/#{Time.new.strftime('%F')}.dat"
    @writer = BinaryWriter.new
    @writer.write :byte_array, IO.get_bytes(IO.read(@filename, mode: 'rb')) if File.exists?(@filename)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Escreve uma mensagem no relatório.
  #---------------------------------------------------------------------------------------------------------------------
  def write(type, text)
    text = "[#{@date}] #{text}"
    @writer.write :byte, HEADER[type]
    @writer.write :string, text

    if DEBUG
      case type
      when :normal
        puts text.colorize(:white)
      when :warning
        puts text.colorize(:yellow)
      when :error
        puts text.colorize(:red)
      end
    end
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Inspeciona o relatório de uma data específica.
  #---------------------------------------------------------------------------------------------------------------------
  def inspect(date)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Salva o relatório.
  #---------------------------------------------------------------------------------------------------------------------
  def save
    @writer.save @filename
  end
end