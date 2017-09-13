class Server
  attr_reader :clients

  def initialize
    @clients = Array.new(60)
    @available_indices = []
    @high_index = 0
    @users_online = []
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Obtém o próximo id livre.
  #---------------------------------------------------------------------------------------------------------------------
  def get_next_id
    if @available_indices.size >= 1
      return @available_indices.pop
    else
      @high_index += 1
      return @high_index
    end
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Adiciona um jogador.
  #---------------------------------------------------------------------------------------------------------------------
  def push(client)
    client.id = get_next_id
    @clients[client.id] = client
    client.id
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Remove um jogador que se deconectou.
  #---------------------------------------------------------------------------------------------------------------------
  def remove(cid)
    return if @clients[cid].nil?

    @users_online.delete(@clients[cid].name) if @clients[cid].entered?

    @clients[cid].save
    @clients[cid].close_connection
    @clients[cid] = nil
    @available_indices << cid
  end
end