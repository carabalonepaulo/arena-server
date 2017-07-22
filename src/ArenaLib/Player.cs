using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace ArenaLib {
    class Player {
        /// <summary>
        /// Identificador global do jogador.
        /// </summary>
        public int Id;

        /// <summary>
        /// Nome de exibição.
        /// </summary>
        public string Name;

        /// <summary>
        /// Instância da socket.
        /// </summary>
        public TcpClient Client;

        /// <summary>
        /// Stream entre o servidor e o jogador.
        /// </summary>
        public NetworkStream Stream;

        /// <summary>
        /// Buffer usado para receber dados.
        /// </summary>
        public byte [] Buffer;

        /// <summary>
        /// Tamanho do buffer.
        /// </summary>
        public int BufferSize = 512;

        /// <summary>
        /// Identificador da sala.
        /// </summary>
        public int RoomId = -1;

        /// <summary>
        /// Se o jogador está no lobby.
        /// </summary>
        public bool InLobby { get { return RoomId >= 0; } private set { } }

        /// <summary>
        /// Se o jogador está em uma sala.
        /// </summary>
        public bool InRoom { get { return !InLobby; } private set { } }

        /// <summary>
        /// Envia um pacote de dados pro jogador.
        /// </summary>
        /// <param name="packet"></param>
        public void Send (Packet packet) {
            Client.Client.Send (packet.Recycle ());
        }
    }
}
