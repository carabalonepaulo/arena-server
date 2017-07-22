using System.Net.Sockets;

namespace ArenaLib {
    class User {
        public string Name;
        public string Password;
        public string Email;

        public string Nick;
        public int Level;
        public int Exp;

        public long Gold;
        public long Cash;

        public bool InGame = false;
    }
}