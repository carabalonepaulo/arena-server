using System;
using ArenaLib;

namespace Universe {
    class Server2 {
        public const byte FAIL = 0;
        public const byte SUCCESS = 1;

        /// <summary>
        /// Processa as mensagens de um determinado jogador.
        /// </summary>
        /// <param name="index"></param>
        static void HandleData (int index, byte [] buff) {
            Packet reader = new Packet (buff);
            byte header = reader.ReadByte ();

            switch (header) {
                // Handshake
                case 0:
                    Handshake (index, reader.ReadInt ());
                    break;
                // Login
                case 1:
                    Login (index, reader.ReadString (), reader.ReadString ());
                    break;
                // Registro
                case 3:
                    Register (index, reader.ReadString (), reader.ReadString ());
                    break;
                // Motd
                case 4:
                    SendMotd (index);
                    break;
            }

            if (reader.CanRead ()) { HandleData (index, reader.Recycle ()); }
        }

        /// <summary>
        /// Processo de autenticação do servidor.
        /// </summary>
        /// <param name="pi"></param>
        static void Handshake (int pi, int version) {
            
        }

        /// <summary>
        /// Autentica as credenciais de acesso ao jogo caso sejam válidas.
        /// </summary>
        /// <param name="pi"></param>
        /// <param name="name"></param>
        /// <param name="pass"></param>
        static void Login (int pi, string name, string pass) {
            
        }

        /// <summary>
        /// Registra um novo usuário caso ainda não exista.
        /// </summary>
        /// <param name="pi">Índice do jogador que enviou o pedido de registro.</param>
        /// <param name="name">Nome do usuário.</param>
        /// <param name="pass">Senha do usuário.</param>
        static void Register (int pi, string name, string pass) {
            
        }

        /// <summary>
        /// Envia a mensagem do dia para o jogador.
        /// </summary>
        /// <param name="pi"></param>
        static void SendMotd (int pi) {
            
        }
    }
}
