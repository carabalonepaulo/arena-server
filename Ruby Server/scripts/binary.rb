class String
  def bytesize
    s = 0
    each_byte { s += 1}
    return s
  end
end

# Tamanho em bytes.
SIZEOF = {
    :byte => 1,
    :bool => 1,
    :short => 2,
    :int => 4,
    :float => 4,
    :double => 8,
    :long => 8
}

# Direttriz do tipo.
DOF = {
    :byte => 'c',
    :bool => 'c',
    :short => 's',
    :int => 'i',
    :float => 'F',
    :double => 'd',
    :long => 'l',
    :string => 'A*'
}

class BinaryWriter
  def initialize
    @buffer = []
    @pack = ''
    @size = 0
  end
  #-----------------------------------------------------------------------------
  # Salva o que foi escrito em um arquivo.
  #-----------------------------------------------------------------------------
  def save(filename)
    File.open(filename, 'wb') { |f| f.write(to_s) }
  end
  #-----------------------------------------------------------------------------
  # Escreve um tipo dentro do buffer.
  #-----------------------------------------------------------------------------
  def write(type, value)
    case type
    when :string
      write(:int, value.bytesize)
      value.each_byte { |b| write(:byte, b) }
    when :bool
      write(:byte, value ? 1 : 0)
    when :byte_array
      value.each { |b| write(:byte, b) }
    else
      @size += SIZEOF[type]
      @buffer << value
      @pack << DOF[type]
    end
  end
  #-----------------------------------------------------------------------------
  # Retorna o tamanho em bytes do buffer.
  #-----------------------------------------------------------------------------
  def size
    @size
  end
  #-----------------------------------------------------------------------------
  # Verifica se o buffer está vazio.
  #-----------------------------------------------------------------------------
  def empty?
    @size == 0
  end
  #-----------------------------------------------------------------------------
  # Limpa o buffer.
  #-----------------------------------------------------------------------------
  def clear
    @buffer = []
    @pack = ''
    @size = 0
  end
  #-----------------------------------------------------------------------------
  # Retorna o buffer.
  #-----------------------------------------------------------------------------
  def to_s
    return @buffer.pack(@pack)
  end
  #-----------------------------------------------------------------------------
  # Testa os componentes para validar os métodos.
  #-----------------------------------------------------------------------------
  def test
    puts @buffer.size <= @size
    puts @buffer.size == @pack.size
    puts @pack.size != @size
  end
end

class BinaryReader
  def initialize(bytes)
    if bytes.is_a?(BinaryWriter)
      @buffer = bytes.to_s
      @mode = :bin
    elsif bytes.is_a?(String)
      @buffer = bytes
      @mode = :bin
    else
      @buffer = bytes
      @mode = :array
    end
    @position = 0
  end
  #-----------------------------------------------------------------------------
  # Retorna a posição atual do cursor.
  #-----------------------------------------------------------------------------
  def position
    @position
  end
  #-----------------------------------------------------------------------------
  # Retorna o tamanho atual do buffer.
  #-----------------------------------------------------------------------------
  def size
    @buffer.size
  end
  #-----------------------------------------------------------------------------
  # Retorna uma array com os bytes que não foram lidos.
  #-----------------------------------------------------------------------------
  def unread
    nbuff = IO.get_bytes(@buffer[position, size]).pack('c*')
    clear
    nbuff
  end
  #-----------------------------------------------------------------------------
  # Verifica se ainda é possível ler o buffer.
  #-----------------------------------------------------------------------------
  def can_read?(t = nil)
    return position < size if t.nil?
    return position + t <= size
  end
  #-----------------------------------------------------------------------------
  # Limpa o buffer.
  #-----------------------------------------------------------------------------
  def clear
    @buffer = []
    @position = 0
    @mode = :array
  end
  #-----------------------------------------------------------------------------
  # Consome 'n' na posição.
  #-----------------------------------------------------------------------------
  def eat(n)
    @position += n
  end
  #-----------------------------------------------------------------------------
  # Lê um tipo do buffer.
  #-----------------------------------------------------------------------------
  def read(type)
    if type == :bool
      return read(:byte) == 1
    else
      size = type == :string ? read(:int) : SIZEOF[type]
      buff = []
      if @mode == :bin
        @buffer[position, size].each_byte { |byte| buff << byte }
      else
        @buffer[position, size].each { |byte| buff << byte }
      end
      eat(size)
      return buff.pack('c*').unpack(DOF[type])[0]
    end
  end
end

class IO  
  def self.get_bytes(data)
    bytes = []
    if data.is_a?(Array)
      data.each { |b| bytes << b }
    elsif data.is_a?(String)
      data.each_byte { |b| bytes << b }
    end
    return bytes
  end

  def self.write_bytes(filename, buff)
    if buff.is_a?(Array)
      File.open(filename, 'wb') { |f| f.write(buff.pack('c*')) }
    elsif buff.is_a?(String)
      File.open(filename, 'wb') { |f| f.write(buff) }
    end
  end
end