class Client < EventMachine::Connection
  attr_accessor :id
  attr_reader :name
  attr_reader :group
  attr_reader :characters_count

  def initialize
    super
    @id = -1
    @name = ''
    @group = 'player'
    @characters_count = 0

    @entered = false
    @char_id = -1
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Jogador está em jogo? (No mapa...)
  #---------------------------------------------------------------------------------------------------------------------
  def in_game?
    @char_id >= 0
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Jogador está online? (Após login...)
  #---------------------------------------------------------------------------------------------------------------------
  def entered?
    @entered
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Carrega os dados da conta (somente após o login).
  #---------------------------------------------------------------------------------------------------------------------
  def load(account)
    @name = account.name
    @password = account.password
    @group = account.group
    @email = account.email
    @characters_count = account.characters_count
    @entered = true

    $logger.write :normal, "Usuario ##{@id} se autenticou como '#{@name}'."
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Salva os dados do jogador.
  #---------------------------------------------------------------------------------------------------------------------
  def save
    return if @name == ''
    #TODO: Salvar todos os dados do personagem.
    $database.save_account(@name, @password, @group, @email, @characters_count)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Quando uma conexão é formada.
  #---------------------------------------------------------------------------------------------------------------------
  def post_init
    id = $server.push(self)
    $logger.write :normal, "Usuario ##{id} se conectou."
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Recebe os dados para processá-los.
  #---------------------------------------------------------------------------------------------------------------------
  def receive_data(data)
    bytes = IO.get_bytes(data)
    $server.handle_data(@id, bytes)
    $logger.write :normal, "Usuario ##{@id} enviou #{bytes.size} bytes."
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Se desvincula do servidor.
  #---------------------------------------------------------------------------------------------------------------------
  def unbind
    $server.remove(@id)
    $logger.write :normal, "Usuario ##{@id} se desconectou."
  end
end