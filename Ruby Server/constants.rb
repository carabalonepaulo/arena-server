DEBUG = true

MAX_USERS = 60
MAX_CHARS = 5

GAME_VERSION = 129837

# Resultados de autenticação.
RES_USER_EXISTS = 0
RES_USER_ONLINE = 1
RES_WRONG_USER = 2
RES_WRONG_PASS = 3
RES_ALLOW = 4

# Cabeçalhos
HHANDSHAKE = 0
HLOGIN = 1
HREGISTER = 2
HSYSTEM = 3
HMOTD = 4
HSLOTS = 5
HEXIT = 6
HASKCHARACTER = 7

# Data Packets
SYSTEM = 3
ITEMS = 4
WEAPONS = 5
ARMORS = 6

SWITCHES = 5

# Mensagem do dia.
MOTD = 'Arena v0.1.6 - ALPHA'

# Quantidade de caracteres permitidos para nomes e senhas.
CHARACTERS_LEN = { :min => 6, :max => 12 }

DAMAGE_TYPES = { :none => 0, :physical => 1, :magical => 2 }

ITEM_AOE_TYPEs = { :none => 0, :allies => 1, :self => 2 }
