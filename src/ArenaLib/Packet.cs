using System;
using System.IO;
using System.Net.Sockets;
using System.Text;

namespace ArenaLib {
    class Packet : IDisposable {
        bool reading;
        MemoryStream readStream;
        BinaryReader reader;

        bool writing;
        MemoryStream writeStream;
        BinaryWriter writer;

        int readSize;
        int readPos;

        public int Size { get { return readSize; } private set { } }

        public Packet (byte [] bytes = null) {
            if (bytes != null) {
                reading = true;
                writing = false;
                readSize = bytes.Length;
                readPos = 0;

                readStream = new MemoryStream (bytes);
                reader = new BinaryReader (readStream);
            } else {
                reading = false;
                writing = true;

                writeStream = new MemoryStream ();
                writer = new BinaryWriter (writeStream);
            }
        }

        /// <summary>
        /// Escreve um byte.
        /// </summary>
        /// <param name="b"></param>
        public void WriteByte (byte b) {
            writer.Write (b);
        }

        /// <summary>
        /// Escreve um short.
        /// </summary>
        /// <param name="s"></param>
        public void WriteShort (short s) {
            writer.Write (s);
        }

        /// <summary>
        /// Escreve um int.
        /// </summary>
        /// <param name="i"></param>
        public void WriteInt (int i) {
            writer.Write (i);
        }

        /// <summary>
        /// Escreve uma string.
        /// </summary>
        /// <param name="s"></param>
        public void WriteString (string s) {
            writer.Write (s.Length);
            char [] chars = s.ToCharArray ();
            for (int j = 0; j < s.Length; j++)
                writer.Write (chars [j]);
        }

        /// <summary>
        /// Lê um byte.
        /// </summary>
        /// <returns></returns>
        public byte ReadByte () {
            readPos += 1;
            return reader.ReadByte ();
        }

        /// <summary>
        /// Lê um short.
        /// </summary>
        /// <returns></returns>
        public short ReadShort () {
            readPos += 2;
            return reader.ReadInt16 ();
        }

        /// <summary>
        /// Lê um int.
        /// </summary>
        /// <returns></returns>
        public int ReadInt () {
            readPos += 4;
            return reader.ReadInt32 ();
        }

        /// <summary>
        /// Lê uma string.
        /// </summary>
        /// <returns></returns>
        public string ReadString () {
            int len = ReadInt ();
            readPos += len;
            StringBuilder sb = new StringBuilder ();
            for (int j = 0; j < len; j++)
                sb.Append (reader.ReadChar ());
            return sb.ToString ();
        }

        /// <summary>
        /// Verifica se é possível ler.
        /// </summary>
        /// <returns></returns>
        public bool CanRead () {
            return readSize > reader.BaseStream.Position;
        }

        /// <summary>
        /// Recicla os bytes não lidos para serem usados depois.
        /// </summary>
        /// <returns></returns>
        public byte [] Recycle () {
            if (reading) {
                byte [] allBytes = readStream.ToArray ();
                byte [] unreadBytes = new byte [allBytes.Length - readPos];
                Array.Copy (allBytes, readPos, unreadBytes, 0, allBytes.Length - readPos);

                readStream.Dispose ();
                reader.Dispose ();

                return unreadBytes;
            } else {
                byte [] bytes = writeStream.ToArray ();
                writeStream.Dispose ();
                writer.Dispose ();

                return bytes;
            }
        }

        /// <summary>
        /// Recebe os bytes de uma determinada socket.
        /// </summary>
        /// <param name="socket"></param>
        /// <returns></returns>
        public static byte[] ReceiveBytes (Socket socket) {
            int size = socket.Available;
            byte [] buffer = new byte [size];
            socket.Receive (buffer, 0, size, SocketFlags.None);
            return buffer;
        }

        /// <summary>
        /// Libera a memória utilizada.
        /// </summary>
        public void Dispose () {
            if (reading) {
                reader.Dispose ();
                readStream.Dispose ();
                readPos = 0;
                readSize = 0;
            } else {
                writer.Dispose ();
                writeStream.Dispose ();
            }
        }
    }
}
