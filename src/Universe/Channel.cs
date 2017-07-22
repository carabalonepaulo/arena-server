using System.Xml;
using ArenaLib;
using System.Net.Sockets;
using System.Net;
using System.Threading;

namespace Universe {
    class Channel {
        /// <summary>
        /// Caminho para o arquivo de configuração.
        /// </summary>
        public const string ConfigFilePath = "./config.xml";

        /// <summary>
        /// Identificador do canal.
        /// </summary>
        public int Id;

        /// <summary>
        /// Nome de exibição.
        /// </summary>
        public string Name;

        /// <summary>
        /// Endereço de IP do canal.
        /// </summary>
        public string Ip;

        /// <summary>
        /// Porta do canal.
        /// </summary>
        public int Port;

        /// <summary>
        /// Máximo de jogadores.
        /// </summary>
        public int MaxPlayers;

        /// <summary>
        /// Máximo de salas.
        /// </summary>
        public int MaxRooms;

        /// <summary>
        /// Taxa de experiência.
        /// </summary>
        public float ExpRate;

        /// <summary>
        /// Taxa de ouro.
        /// </summary>
        public float GoldRate;

        /// <summary>
        /// Jogadores online.
        /// </summary>
        public Player [] Players;

        /// <summary>
        /// Salas disponíveis.
        /// </summary>
        public Room [] Rooms;

        /// <summary>
        /// Define se o servidor interno está ou não em execução.
        /// </summary>
        public bool Running;

        /// <summary>
        /// Listener.
        /// </summary>
        TcpListener Listener;

        /// <summary>
        /// Thread usada para o processamento lógico do canal.
        /// </summary>
        Thread LogicThread;

        /// <summary>
        /// Rotina de inicialização.
        /// </summary>
        public void Start () {
            Running = true;

            Players = new Player [MaxPlayers];
            Rooms = new Room [MaxRooms];

            Listener = new TcpListener (IPAddress.Any, Port);
            LogicThread = new Thread (() => Run ());
        }

        /// <summary>
        /// Encerra o servidor interno.
        /// </summary>
        public void Stop () {
            Running = false;
            LogicThread.Abort ();
            Listener.Stop ();

            for (int i = 0; i < MaxRooms; i++)
                Rooms [i].Close ();

            for (int i = 0; i < MaxPlayers; i++)
                Players [i].Client.Close ();


        }

        /// <summary>
        /// Inicialização do servidor dentro do canal.
        /// </summary>
        public void Run () {
            while (Running) {
                Update ();
            }
        }       

        /// <summary>
        /// Ciclo de atualizações do canal.
        /// </summary>
        public void Update () {
            for (int i = 0; i < MaxRooms; i++) {
                if (Rooms [i] != null)
                    Rooms [i].Update ();
            }
        }

        public void Add (Player player) {
            //int index = 
        }

        /// <summary>
        /// Remove um jogador do canal e retorna a instância do mesmo.
        /// </summary>
        /// <returns></returns>
        public Player Remove (int index) {
            Player temp = Players [index];
            Players [index] = null;
            return temp;
        }
    }
}
