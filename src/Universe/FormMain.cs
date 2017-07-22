using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace Universe {
    public partial class FormMain : Form {
        #region Peek Message
        [System.Security.SuppressUnmanagedCodeSecurity]
        [DllImport ("User32.dll", CharSet = CharSet.Auto)]
        public static extern bool PeekMessage (out Message msg, IntPtr hWnd, uint messageFilterMin, uint messageFilterMax, uint flags);

        /// <summary>Windows Message</summary>
        [StructLayout (LayoutKind.Sequential)]
        public struct Message {
            public IntPtr hWnd;
            public IntPtr msg;
            public IntPtr wParam;
            public IntPtr lParam;
            public uint time;
            public Point p;
        }

        public void OnApplicationIdle (object sender, EventArgs e) {
            while (AppStillIdle)
                Server.Instance.Update ();
        }

        private bool AppStillIdle {
            get {
                Message msg;
                return !PeekMessage (out msg, IntPtr.Zero, 0, 0, 0);
            }
        }
        #endregion

        public static FormMain Instance;

        public FormMain () {
            InitializeComponent ();
        }

        /// <summary>
        /// Inicialização do servidor.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void iniciarToolStripMenuItem_Click (object sender, EventArgs e) {
            Server.Instance = new Server ("./config.xml");
            Server.Instance.Start ();
        }

        private void pararToolStripMenuItem_Click (object sender, EventArgs e) {
            Server.Instance.Stop ();
        }
    }
}
