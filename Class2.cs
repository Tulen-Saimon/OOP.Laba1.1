using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace OOP.Laba1._1
{
    public class Libraly

    {
        public List<Book> libra = new List<Book>();
        public string n, a, g;

        public void add1()
        {
            Form1 per = new Form1();
            Book boock = new Book();
            boock.Name = n;
            boock.Avtor = a;
            boock.GodIzd = g;
            add(boock);
        }

        private void add(Book boock)
        {
            libra.Add(boock);
        }
    }
}
