using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace CharaObjConv
{
    internal class Program
    {
        private static void XorFF(byte[] bytes, int count)
        {
            for (int i = 0; i < count; i++)
            {
                bytes[i] ^= byte.MaxValue;
            }
        }

        private static void MergeObjs(string infolder)
        {
            foreach (string item3 in Directory.EnumerateFiles(infolder, "*.txt"))
            {
                string[] array = File.ReadAllLines(item3);
                string text = Path.Combine(infolder, Path.GetFileNameWithoutExtension(item3) + ".obj");
                byte[] array2 = File.ReadAllBytes(text);
                Console.WriteLine(text);
                int num = BitConverter.ToInt32(array2, array2.Length - 4);
                int num2 = BitConverter.ToInt32(array2, array2.Length - 8);
                int num3 = array2.Length - num2 - num * 4 - 8;
                int srcOffset = array2.Length - num2 - 8;
                XorFF(array2, num * 4 + num3);
                int num4 = num2;
                List<int> list = new List<int>();
                int num5 = array2.Length - 8 - num4;
                for (int i = 0; i < num4; i++)
                {
                    byte b = array2[num5 + i];
                    if (b != 1)
                    {
                        list.Add(i);
                    }
                }
                MemoryStream memoryStream = new MemoryStream();
                List<string> list2 = new List<string>();
                List<int> list3 = new List<int>();
                List<int> list4 = new List<int>();
                string[] array3 = array;
                foreach (string text2 in array3)
                {
                    if (!text2.StartsWith("//"))
                    {
                        int item;
                        if (list2.Contains(text2))
                        {
                            int index = list2.IndexOf(text2);
                            item = list3[index];
                        }
                        else
                        {
                            list2.Add(text2);
                            item = (int)memoryStream.Position;
                            byte[] bytes = Encoding.GetEncoding("SJIS").GetBytes(text2);
                            memoryStream.Write(bytes, 0, bytes.Length);
                            memoryStream.WriteByte(0);
                            //memoryStream.WriteByte(0);
                            list3.Add(item);
                        }
                        list4.Add(item);
                    }
                }
                memoryStream.WriteByte(32);
                //memoryStream.WriteByte(0);
                memoryStream.WriteByte(32);
                //memoryStream.WriteByte(0);
                memoryStream.WriteByte(32);
                //memoryStream.WriteByte(0);
                memoryStream.WriteByte(32);
                //memoryStream.WriteByte(0);
                //memoryStream.WriteByte(0);
                //memoryStream.WriteByte(0);
                MemoryStream memoryStream2 = new MemoryStream();
                BinaryWriter binaryWriter = new BinaryWriter(memoryStream2);
                int num6 = 0;
                for (int k = 0; k < num * 4; k += 4)
                {
                    int value = BitConverter.ToInt32(array2, k);
                    int item2 = k / 4 % num4;
                    if (list.Contains(item2))
                    {
                        binaryWriter.Write(list4[num6]);
                        num6++;
                    }
                    else
                    {
                        binaryWriter.Write(value);
                    }
                }
                byte[] array4 = new byte[memoryStream2.Length + memoryStream.Length + num2 + 8];
                Buffer.BlockCopy(memoryStream2.ToArray(), 0, array4, 0, (int)memoryStream2.Length);
                Buffer.BlockCopy(memoryStream.ToArray(), 0, array4, (int)memoryStream2.Length, (int)memoryStream.Length);
                Buffer.BlockCopy(array2, srcOffset, array4, (int)(memoryStream2.Length + memoryStream.Length), num2 + 8);
                XorFF(array4, array4.Length - num2 - 8);
                File.WriteAllBytes(text, array4);
            }
        }

        private static void ExtractObjs(string infolder)
        {
            foreach (string item in Directory.EnumerateFiles(infolder, "*.obj"))
            {
                Console.WriteLine(item);
                byte[] array = File.ReadAllBytes(item);

                int num = BitConverter.ToInt32(array, array.Length - 4);
                int num2 = BitConverter.ToInt32(array, array.Length - 8);
                int num3 = array.Length - num2 - num * 4 - 8;
                int num4 = num * 4;
                XorFF(array, num * 4 + num3);

                File.WriteAllBytes(item + ".unc", array);

                List<byte> list = new List<byte>();
                List<string> list2 = new List<string>();
                List<int> list3 = new List<int>();
                Dictionary<int, string> dictionary = new Dictionary<int, string>();
                int num5 = 0;
                for (int i = 0; i < num3; i += 1)
                {
                    byte b = array[num4 + i];
                    //byte b2 = array[num4 + i + 1];
                    if (b == 0)// && b2 == 0)
                    {
                        string @string = Encoding.GetEncoding("SJIS").GetString(list.ToArray());
                        list2.Add(@string);
                        list.Clear();
                        list3.Add(num5);
                        dictionary.Add(num5, @string);
                        num5 = i + 1;
                    }
                    else
                    {
                        list.Add(b);
                        //list.Add(b2);
                    }
                }
                string text = "";
                int num6 = num2;
                List<int> list4 = new List<int>();
                int num7 = array.Length - 8 - num6;
                for (int j = 0; j < num6; j++)
                {
                    byte b3 = array[num7 + j];
                    if (b3 != 1)
                    {
                        list4.Add(j);
                    }
                }
                if (num6 == -1)
                {
                    Console.WriteLine("Cannot handle this obj file, skipping...");
                }
                else
                {
                    int num8 = 0;
                    for (int k = 0; k < num * 4; k += 4)
                    {
                        int key = BitConverter.ToInt32(array, k);
                        key.ToString();
                        int num9 = k / 4 % num6;
                        if (num9 == 0)
                        {
                            object obj = text;
                            text = obj + "//entry " + num8 + " -----------------------" + Environment.NewLine;
                            num8++;
                        }
                        if (list4.Contains(num9))
                        {
                            string str = dictionary[key];
                            text = text + str + Environment.NewLine;
                        }
                    }
                    File.WriteAllText(Path.Combine(infolder, Path.GetFileNameWithoutExtension(item) + ".txt"), text);
                }
            }
        }

        private static void Main(string[] args)
        {
            if (args.Length != 2)
            {
                Console.WriteLine("Usage: \n To extract, use option '-extract foldername'.\n To merge, use '-merge foldername'.");
                return;
            }
            string infolder = args[1];
            if (args[0] == "-extract")
            {
                ExtractObjs(infolder);
                Console.WriteLine("Done");
            }
            if (args[0] == "-merge")
            {
                MergeObjs(infolder);
                Console.WriteLine("Done");
            }
        }
    }
}
