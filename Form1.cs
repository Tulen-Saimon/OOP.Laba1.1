using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Collections.Generic;

namespace OOP.Laba1._1
{
    public partial class Form1 : Form
    {
        Libraly kniga = new Libraly();
        Book buk = new Book();
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            kniga.n = textBox1.Text;
            kniga.g = textBox2.Text;
            kniga.a = textBox3.Text;
            kniga.add1();
            listBox1.Items.Clear();
            foreach (Book i in kniga.libra)
                listBox1.Items.Add(i.Avtor + " " + i.GodIzd + " " + i.Name);
        }

        private void button2_Click(object sender, EventArgs e)
        {

        }

        private void button3_Click(object sender, EventArgs e)
        {
            if (radioButton1.Checked)
            {
                kniga.a = textBox3.Text;
                listBox2.Items.Clear();
                foreach (Book i in kniga.libra)
                {
                    if (i.Avtor == kniga.a)
                    {
                        
                       listBox2.Items.Add(i.Avtor + " " + i.GodIzd + " " + i.Name);

                    }


                }
            }
        }
    }
}
