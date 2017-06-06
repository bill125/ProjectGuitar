/*
  note(7bit) 20-14
  interval(10bit) 13-4
  pos(3bit) 3-1
  end(1bit) 0-0
 */
#include <iostream>
#include <fstream>
using namespace std;
const int TotalBit = 7 + 10 + 1 + 1;
const int base_string_note[] = {40, 45, 50, 55, 59, 64};
const int note_array[] = {0, 0, 2, 4, 5, 7, 9, 11, 12};
int get_pos(int note, int capo)
{
	for (int i = 0; i < 6; ++i)
		if (base_string_note[i] + capo > note) return max(i - 1, 0);
	return 5;
}
void work(string in_file, string ou_file, int show)
{
	ifstream fin(in_file);
	ofstream fout(ou_file, std::ios_base::binary);
	int base_note, capo;
	fin >> base_note >> capo;
	cout << base_note << '\n';
	char c, lastc = '+';
	int note, delta, interval = 0;
	while (fin >> c) {
		if (c != '+' && c != '-' && c != '/') continue;
		cout << c << endl;
		if (c == '+' || c == '/') {
			fin >> note >> delta;
			note = note_array[note];
			note += base_note + 12 * delta;
			int End = (c == '/');
			int data = (note << 10) + interval, pos = get_pos(note, capo);
			data = (data << 3) + pos;
			data = (data << 1) + End;
			cout << "data=" << data << '\n';
			cout << note << ' '<<interval << ' ' << pos << ' '<< End << '\n';
			unsigned char s[10];
			memcpy(s, (char*)&data, sizeof(int));
			reverse(s, s + 4);
			for (int i = 0; i < 4; ++i) {
				if (s[i] > 127 || s[i] < 32) cout <<'['<< (int)s[i] << ']';
				else cout << s[i];
			}
			cout << '\n';
			fout.write((char*)(s + 1), sizeof(char) * 3);
			interval = 1;
		}else if (lastc == '+') {
			fin >> interval;
		}else {
			int tmp;
			fin >> tmp;
			interval += tmp;
		}
		lastc = c;
		if (c == '/') break;
	}
	fout.close(); fclose(stdin);
}
int main(int argc, char *argv[])
{
	cout << "processing output\n";
	work("input.txt", "../../mif/output-play", 1);
	cout << "processing input-bgm\n";
	work("input-bgm.txt", "../../mif/output-bgm", 0);
    return 0;
}
