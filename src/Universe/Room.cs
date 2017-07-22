using System;
using ArenaLib;

namespace Universe {
    class Room {
        #region Cabeçalhos
        /// <summary>
        /// Cabeçalho de criação.
        /// </summary>
        public const byte HCreate = 10;

        /// <summary>
        /// Cabeçalho de entrada.
        /// </summary>
        public const byte HEnter = 11;

        /// <summary>
        /// Cabeçalho de saída.
        /// </summary>
        public const byte HLeave = 12;

        /// <summary>
        /// Cabeçalho de falha ao entrar.
        /// </summary>
        public const byte HFail = 13;

        /// <summary>
        /// Novo proprietário da sala.
        /// </summary>
        public const byte HNewOwner = 14;
        #endregion

        /// <summary>
        /// Instância do servidor.
        /// </summary>
        public Server Server;

        /// <summary>
        /// Canal onde a sala está localizada.
        /// </summary>
        public Channel Channel;

        /// <summary>
        /// Id da sala dentro do lobby.
        /// </summary>
        public int Id;

        /// <summary>
        /// Id do proprietário da sala. 
        /// </summary>
        public int OwnerId;

        /// <summary>
        /// Quantidade máxima de jogadores na sala.
        /// </summary>
        public int MaxPlayers;

        /// <summary>
        /// Id do mapa que será jogado nesta sala.
        /// </summary>
        public int MapId;

        /// <summary>
        /// Lista dos jogadores que estão na sala (inclui o proprietário).
        /// </summary>
        public Player [] Players;

        /// <summary>
        /// Quantidade de jogadores na sala.
        /// </summary>
        int playersCount;

        public Room (Server server, Channel channel, int roomId, int ownerId, int maxPlayers, int mapId) {
            Server = server;
            Channel = channel;

            Id = roomId;
            OwnerId = ownerId;
            MaxPlayers = maxPlayers;
            MapId = mapId;

            Players = new Player [MaxPlayers];
            playersCount = 1;
        }

        /// <summary>
        /// Envia um pacote para todos na sala.
        /// </summary>
        /// <param name="p"></param>
        void Send (Packet p) {
            for (int i = 0; i < MaxPlayers; i++) {
                if (Players [i] != null)
                    Players [i].Send (p);
            }
        }

        /// <summary>
        /// Obtém um slot livre dentro da sala.
        /// </summary>
        /// <returns></returns>
        int GetFreeSlot () {
            int index = -1;
            for (int i = 0; i < MaxPlayers; i++) {
                if (Players [i] == null) {
                    index = i;
                    break;
                }
            }
            return index;
        }

        /// <summary>
        /// Obtém o próximo slot que possui um jogador.
        /// </summary>
        /// <returns></returns>
        int GetNextActiveSlot () {
            int index = -1;
            for (int i = 0; i < MaxPlayers; i++) {
                if (Players [i] != null) {
                    index = i;
                    break;
                }
            }
            return index;
        }

        /// <summary>
        /// Define um novo proprietário da sala.
        /// </summary>
        void SetNewOwner () {
            if (playersCount == 0)
                throw new Exception ("Impossível definir novo líder da sala quando não há jogadores.");

            OwnerId = GetNextActiveSlot ();

            Packet p = new Packet ();
            p.WriteByte (HNewOwner);
            p.WriteInt (OwnerId);

            Send (p);
        }

        /// <summary>
        /// Adiciona o jogador de id especificado à sala.
        /// </summary>
        /// <param name="pi">Índice global do jogador.</param>
        public void Add (int pi) {
            int index = GetFreeSlot ();
            if (index >= 0) {
                // Remove o jogador do lobby e adiciona à sala.
                Players [index] = Channel.Remove (pi);
                playersCount++;

                Packet p = new Packet ();
                p.WriteByte (HEnter);

                // Informações sobre o jogador que entrou na sala.
                p.WriteInt (pi);
                p.WriteString (Server.Players [pi].Name);

                Send (p);

            // Caso a sala esteja cheia uma mensagem de falha é enviada.
            } else {
                Packet p = new Packet ();
                p.WriteByte (HFail);

                Server.Players [pi].Send (p);
            }
        }

        /// <summary>
        /// Remove um jogador da sala.
        /// </summary>
        /// <param name="pi"></param>
        public void Remove (int pi) {
            Packet p = new Packet ();
            p.WriteByte (HLeave);
            p.WriteInt (pi);

            Players [pi].Send (p);
            /*Server.Players [pi].RoomId = -1;

            int rid = GetRelativeIndex (pi);
            PID [rid] = 0;*/
            playersCount--;
        }

        /// <summary>
        /// Fecha a sala.
        /// TODO: Mover todos os jogadores para o Lobby.
        /// </summary>
        public void Close () {

        }

        /// <summary>
        /// Ciclo de atualizações da sala.
        /// </summary>
        public void Update () {

        }
    }
}
