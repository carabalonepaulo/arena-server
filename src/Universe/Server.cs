using ArenaLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Xml;

namespace Universe {
    class Server {
        public static Server Instance;
        public static bool Running = false;

        /// <summary>
        /// Lista de canais.
        /// </summary>
        public Channel [] Channels;

        /// <summary>
        /// Lista de usuários.
        /// </summary>
        List<User> Users;

        /// <summary>
        /// Lista de jogadores online.
        /// </summary>
        List<Player> Players;

        /// <summary>
        /// Instância do listener.
        /// </summary>
        TcpListener Listener;

        /// <summary>
        /// Carrega a lista de canais.
        /// </summary>
        /// <returns></returns>
        Channel [] LoadChannels () {
            Console.WriteLine ("Carregando canais...");

            XmlDocument xml = new XmlDocument ();
            xml.Load ("./channels.xml");

            XmlNodeList list = xml.SelectNodes ("channels/channel");
            Channel [] channels = new Channel [list.Count];

            for (int i = 0; i < list.Count; i++) {

                channels [i] = new Channel () {
                    Name = list [i].Attributes ["name"].InnerText,
                    Ip = list [i].Attributes ["ip"].InnerText,
                    Port = Convert.ToInt32 (list [i].Attributes ["port"].InnerText),

                    MaxPlayers = int.Parse (list [i].ChildNodes [0].ChildNodes [0].InnerText),
                    MaxRooms = int.Parse (list [i].ChildNodes [0].ChildNodes [1].InnerText),

                    ExpRate = float.Parse (list [i].ChildNodes [1].ChildNodes [0].InnerText),
                    GoldRate = float.Parse (list [i].ChildNodes [1].ChildNodes [1].InnerText),
                };
                channels [i].Start ();
            }
            return channels;
        }

        /// <summary>
        /// Carrega os usuários registrados.
        /// </summary>
        /// <returns></returns>
        User [] LoadUsers () {
            Console.WriteLine ("Carregando usuários...");

            XmlDocument xml = new XmlDocument ();
            xml.Load ("./users.xml");

            XmlNodeList list = xml.SelectNodes ("users/user");
            User [] users = new User [list.Count];

            for (int i = 0; i < list.Count; i++)
                users [i] = new User () {
                    Name = list [i].Attributes ["name"].InnerText,
                    Password = list [i].Attributes ["password"].InnerText,
                    Email = list [i].Attributes ["email"].InnerText,

                    Nick = list [i].ChildNodes [0].InnerText,
                    Gold = Convert.ToInt32 (list [i].ChildNodes [1].InnerText),
                    Cash = Convert.ToInt32 (list [i].ChildNodes [2].InnerText),
                };
            return users;
        }


        /// <summary>
        /// Inicia o servidor.
        /// </summary>
        public void Start () {
            Running = true;
            Channels = LoadChannels ();
            Users = new List<User> ();
            Users.AddRange (LoadUsers ());
            Players = new List<Player> ();

            Listener = new TcpListener (IPAddress.Any, 5810);
            Listener.Start (32);
            Listener.BeginAcceptTcpClient (OnConnectRequest, Listener);
        }

        /// <summary>
        /// Para o servidor.
        /// </summary>
        public void Stop () {
            Running = false;
            Users.Clear ();
            Players.Clear ();
            Channels
                .Where (c => c != null)
                .Select (c => c = null);
        }

        /// <summary>
        /// Callback para novas conexões
        /// </summary>
        /// <param name="ar"></param>
        void OnConnectRequest (IAsyncResult ar) {
            var listener = (TcpListener)ar.AsyncState;
            var client = listener.EndAcceptTcpClient (ar);
            var stream = client.GetStream ();
            var player = new Player () {
                Client = client,
                Stream = stream
            };

            stream.BeginRead (player.Buffer, 0, player.BufferSize, OnRead, player);
            listener.BeginAcceptTcpClient (OnConnectRequest, Listener);
        }

        /// <summary>
        /// Callback para recebimento de mensagens.
        /// </summary>
        /// <param name="ar"></param>
        void OnRead (IAsyncResult ar) {
            try {
                var player = (Player)ar.AsyncState;
                int length = player.Stream.EndRead (ar);
                if (length <= 0) {
                    player.Client.Close ();
                    if (Players.Contains (player))
                        Players.Remove (player);
                } else {
                    /* O padrão de mensagens trocadas entre client/server é: {header}{message}{separador}
                       O header sempre terá 3 caracteres de comprimento, já a mensagem é ilimitada, ao final
                       é adicionado um "\n" como separador. */
                    
                }
            } catch (SocketException) { }
        }
    }
}
