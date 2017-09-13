class Server

  def send(cid, packet)
    @clients[cid].send_data(packet.to_s)
  end

  def send_to_all(packet)
    @clients.each do |client|
      if client.in_game?
        client.send_data(packet.to_s)
      end
    end
  end

  def send_to_map(map_id, self_id, buff)
    buff = buff.to_s
    @clients.each do |client|
      if client.character != nil && client.character.map_id == map_id && client.id != self_id
        client.send_data(buff)
      end
    end
  end

  def send_hand_shake(cid)
    packet = BinaryWriter.new
    packet.write :byte, HHANDSHAKE
    packet.write :byte, cid
    send cid, packet
  end

  def send_motd(cid)
    packet = BinaryWriter.new
    packet.write :byte, HMOTD
    packet.write :string, MOTD
    send cid, packet
  end

  def send_login(cid, result)
    packet = BinaryWriter.new
    packet.write :byte, HLOGIN
    packet.write :byte, result
    send cid, packet
  end

  def send_register(cid, result)
    packet = BinaryWriter.new
    packet.write :byte, HREGISTER
    packet.write :byte, result
    send cid, packet
  end

  def send_slots(cid)
    writer = BinaryWriter.new
    writer.write :byte, HSLOTS
    (0...MAX_CHARS).each { |i| writer.write :bool, $database.character_exists?(@clients[cid].name, i) }
    send cid, writer
  end
end