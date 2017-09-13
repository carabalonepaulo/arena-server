class Server
  #---------------------------------------------------------------------------------------------------------------------
  # * Recicla os dados que não foram processados ainda.
  #---------------------------------------------------------------------------------------------------------------------
  def recycle(reader)
    if reader.can_read?
      unread = reader.unread
      handle_data(cid, unread)
    end
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Processa os pacotes recebidos.
  #---------------------------------------------------------------------------------------------------------------------
  def handle_data(cid, bytes)
    begin
      if @clients[cid].entered?
        handle_game_packets(cid, bytes)
      else
        handle_system_packets(cid, bytes)
      end
    rescue => e
      $server.remove cid
      $logger.write :error, "#{e.message}\n#{e.backtrace}"
    end
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Processa os pacotes recebidos antes do login.
  #---------------------------------------------------------------------------------------------------------------------
  def handle_system_packets(cid, bytes)
    reader = BinaryReader.new bytes
    header = reader.read :byte

    if @clients[cid].entered?
      case header
      when HREGISTER;   handle_register(cid, reader.read(:string), Digest::SHA256.base64digest(reader.read(:string)), reader.read(:string))
      when HSYSTEM;     $database.save_system(reader.unread)
      end
    else
      case header
      when HHANDSHAKE;  handle_hand_shake(cid, reader.read(:int))
      when HLOGIN;      handle_login(cid, reader.read(:string), Digest::SHA256.base64digest(reader.read(:string)))
      end
    end

    recycle reader
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Processa os pacotes recebidos após do login.
  #---------------------------------------------------------------------------------------------------------------------
  def handle_game_packets(cid, bytes)
    reader = BinaryReader.new bytes
    #header = reader.read :byte

    recycle reader
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Processa "handshake".
  #---------------------------------------------------------------------------------------------------------------------
  def handle_hand_shake(cid, version)
    if version == GAME_VERSION
      send_hand_shake(cid)
      send_motd(cid)
    else
      $server.remove cid
    end
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Processa o pedido de login.
  #---------------------------------------------------------------------------------------------------------------------
  def handle_login(cid, name, password)
    if $database.account_exists?(name)
      if @users_online.include?(name)
        send_login(cid, RES_USER_ONLINE)
      else
        account = $database.load_account(name)
        if account.name == name
          if account.password == password
            @users_online << name
            @clients[cid].load(account)

            send_login(cid, RES_ALLOW)
            send_slots(cid)
          else
            send_login(cid, RES_WRONG_PASS)
          end
        else
          send_login(cid, RES_WRONG_USER)
        end
      end
    else
      send_login(cid, RES_WRONG_USER)
    end
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Processa o pedido de registro.
  #---------------------------------------------------------------------------------------------------------------------
  def handle_register(cid, name, register, email)
    if $database.account_exists?(name)
      send_register(cid, RES_USER_EXISTS)
    else
      $database.save_account(name, password, 'player', email, 0)
      send_register(cid, RES_ALLOW)
    end
  end

  def handle_system
    load_system(reader)
  end
end