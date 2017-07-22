using System;
using System.Windows.Forms;

namespace Universe {
    static class Program {
        /// <summary>
        /// Ponto de entrada principal para o aplicativo.
        /// </summary>
        [STAThread]
        static void Main () {
            Application.EnableVisualStyles ();
            Application.SetCompatibleTextRenderingDefault (false);
            FormMain.Instance = new FormMain ();
            Application.Run (FormMain.Instance);
        }
    }
}
