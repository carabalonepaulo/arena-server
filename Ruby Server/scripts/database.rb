Account = Struct.new(:name, :password, :group, :email, :characters_count)
Character = Struct.new(:account_id, :slot_id, :name, :level, :graphic, :map_id, :x, :y, :str, :agi, :int)

ItemType = { :item => 0, :weapon => 1, :armor => 2 }

class Database
  DATA = './data'
  ACCOUNTS_PATH = "#{DATA}/accounts"
  CHARACTERS_PATH = "#{DATA}/players"
  #---------------------------------------------------------------------------------------------------------------------
  # * Inicia o procedimento de carregamento do banco de dados.
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    load_system if File.exists?("#{DATA}/system.dat")

  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Verifica se a conta existe.
  #---------------------------------------------------------------------------------------------------------------------
  def account_exists?(user_name)
    File.exists?("#{ACCOUNTS_PATH}/#{user_name}.dat")
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Escreve o buffer em um arquivo binário.
  #---------------------------------------------------------------------------------------------------------------------
  def write(filename, buff)
    IO.write(filename, buff, mode: 'wb')
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Lê um arquivo binário.
  #---------------------------------------------------------------------------------------------------------------------
  def read(filename)
    IO.get_bytes(IO.read(filename, mode: 'rb'))
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Salva uma conta, se já existe ela é sobrescrita.
  #---------------------------------------------------------------------------------------------------------------------
  def save_account(name, password, group, email, characters_count)
    writer = BinaryWriter.new
    writer.write :string, name
    writer.write :string, Digest::SHA256.base64digest(password)
    writer.write :string, group
    writer.write :string, email
    writer.write :byte, characters_count
    writer.save "#{ACCOUNTS_PATH}/#{name}.dat"
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Carrega a conta de um usuário.
  #---------------------------------------------------------------------------------------------------------------------
  def load_account(user_name)
    filename = "#{ACCOUNTS_PATH}/#{user_name}.dat"
    if File.exists?(filename)
      reader = BinaryReader.new(read(filename))
      account = Account.new
      account.name = reader.read(:string)
      account.password = reader.read(:string)
      account.group = reader.read(:string)
      account.email = reader.read(:string)
      account.characters_count = reader.read(:byte)
      
      return account
    else
      #TODO: Exceção quando o arquivo não existir.
    end
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Deleta a conta de um usuário.
  #---------------------------------------------------------------------------------------------------------------------
  def delete_account(user_name)
    File.delete("#{ACCOUNTS_PATH}/#{user_name}.dat")
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Verifica se o personagem existe.
  #---------------------------------------------------------------------------------------------------------------------
  def character_exists?(user_name, id)
    File.exists?("#{ACCOUNTS_PATH}/#{user_name}-#{id}.dat")
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Carrega os dados de um personagem.
  #---------------------------------------------------------------------------------------------------------------------
  def load_character(account_name, id)
    filename = "#{CHARACTERS_PATH}/#{account_name}-#{id}.dat"
    if File.exists?(filename)
      reader = Binary_Reader.new(read(filename))

      c = Character.new
      c.account_id  = id
      c.slot_id     = reader.read :int
      c.name        = reader.read(:string)
      c.level       = reader.read(:int)
      c.graphic     = reader.read(:string)
      c.map_id      = reader.read(:int)
      c.x           = reader.read(:int)
      c.y           = reader.read(:int)
      c.str         = reader.read(:int)
      c.agi         = reader.read(:int)
      c.int         = reader.read(:int)

      # Carrega os itens do inventário.
      c.inventory = []
      while reader.can_read?
        case reader.read(:byte)
          when ItemType[:item]
            item = Item.new
            item.name         = reader.read :string
            item.icon         = reader.read :string
            item.description  = reader.read :string
            #item.type = @system.item_types[reader.read(:byte)]
            item.price        = reader.read :int
            item.consumable   = reader.read :bool
            item.aoe          = ITEM_AOE_TYPES[reader.read(:byte)]

            item.speed        = reader.read :int
            item.precision    = reader.read :int
            item.hits         = reader.read :byte
            item.damage_type  = DAMAGE_TYPES[reader.read(:byte)]
            item.animation    = reader.read :int

            c.inventory << item
          when ItemType[:weapon]
            weapon = Weapon.new
            weapon.name             = reader.read :string
            weapon.icon             = reader.read :string
            weapon.description      = reader.read :string
            #weapon.type = @system.weapon_types[reader.read(:byte)]
            weapon.price            = reader.read :int
            weapon.animation        = reader.read :int

            weapon.attack           = reader.read :int
            weapon.defense          = reader.read :int
            weapon.magical_attack   = reader.read :int
            weapon.magical_defense  = reader.read :int
            weapon.hp_max           = reader.read :int
            weapon.mp_max           = reader.read :int

            c.inventory << weapon
          when ItemType[:armor]
            armor = Armor.new
            armor.name             = reader.read :string
            armor.icon             = reader.read :string
            armor.description      = reader.read :string
            #armor.type = @system.armor_types[reader.read(:byte)]
            armor.price            = reader.read :int
            #armor.kind        = reader.read :int

            armor.attack           = reader.read :int
            armor.defense          = reader.read :int
            armor.magical_attack   = reader.read :int
            armor.magical_defense  = reader.read :int
            armor.hp_max           = reader.read :int
            armor.mp_max           = reader.read :int
        end
      end

      c.skills = []
      c
    else
      #TODO: Se não existir personagem no slot?
    end
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Deleta um personagem.
  #---------------------------------------------------------------------------------------------------------------------
  def delete_character(account_name, id)
    File.delete("#{CHARACTERS_PATH}/#{account_name}-#{id}.dat")
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Salva os dados do sistem.
  #---------------------------------------------------------------------------------------------------------------------
  def save_system(bytes)
    reader = BinaryReader.new(bytes)
    writer = BinaryWriter.new
    writer.write(:string, reader.read(:string))
    writer.write(:int, reader.read(:int))
    writer.write(:string, reader.read(:string))
    writer.write(:int, reader.read(:int))
    writer.write(:int, reader.read(:int))
    writer.write(:int, reader.read(:int))
    write('./Data/system.dat', writer.to_b)
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Carrega os dados dos sitema.
  #---------------------------------------------------------------------------------------------------------------------
  def load_system
    reader = BinaryReader.new(read('./data/system.dat'))
    $game_system = Game_System.new
    $game_system.game_title = reader.read :string
    $game_system.version_id = reader.read :int
    $game_system.currency_unit = reader.read :string
    $game_system.elements = []
    $game_system.skill_types = []
    $game_system.weapon_types = []
    $game_system.armor_types = []
    $game_system.switches = []
    $game_system.variables = []
    $game_system.start_map_id = reader.read :int
    $game_system.start_x = reader.read :int
    $game_system.start_y = reader.read :int
  end
  #---------------------------------------------------------------------------------------------------------------------
  # * Salva a lista de itens.
  #---------------------------------------------------------------------------------------------------------------------
  def save_items(bytes)
    reader = BinaryReader(bytes)
    writer = BinaryWriter.new

  end
end