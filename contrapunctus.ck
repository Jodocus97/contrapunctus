TriOsc voice1 => dac;
SinOsc voice2 => dac;

//gain auf 0.5 setzen, damit´s nicht zu laut wird.
0.15 => voice1.gain;
0.15 => voice2.gain;

80 => int maxnote;
40 => int minnote;

[ 0, 2, 4, 5, 7, 9, 11 ] @=> int scale[];

// Initialisierung Rhythmus
// 60 BPM = 1 BPS
// 80 BPM = 80/60 = 1,3
// ms = 1000/BPS (1000ms = 1s)
// 1000/1,3 ~ 770ms
// Ganze Note bei 80 BPM = 3080 ms
500::ms => dur ganze; // 80 BPM
ganze / 2 => dur halbe;
halbe / 2 => dur viertel;
viertel / 2 => dur achtel;
achtel / 2 => dur sechzehntel;

[ganze, halbe, viertel, achtel, sechzehntel] @=> dur notenwerte[];
// Definition der Intervalle; Hauptsächlich zur Vereinfachung
0 => int prime;
1 => int klSekunde;
2 => int grSekunde;
3 => int klTerz;
4 => int grTerz;
5 => int quarte;
6 => int tritonus;
7 => int quinte;
8 => int klSexte;
9 => int grSexte;
10 => int klSeptime;
11 => int grSeptime;
12 => int oktave;

[prime, quarte, quinte, oktave] @=> int perfectCons[];
[klTerz, grTerz, klSexte, grSexte] @=> int imperfectCons[];

int prevInterval[2];
int currentInterval[2];
//int nextInterval[2];

1 => int isImperfect;
0 => int isPerfect;

0 => int jump;
0 => int start;
0 => int stop;

fun int getPerfectInterval(int n){
  return perfectCons[Math.random2(0,n-1)];
}

fun int getImperfectInterval(int n){
  return imperfectCons[Math.random2(0,n-1)];
}

0 => int ctr;

fun void run() {
while(true){
  <<< "Start the Music" >>>;
  int tempInterval;
  <<< ctr >>>;
  if(stop == 1) {
      <<< "Schlusskadenz" >>>;
      break;
  } else if(start == 0){
    <<<"initialise first tone">>>;
    scale[Math.random2(0, scale.size()-1)] => currentInterval[0];
    <<<"First tone is: ", currentInterval[0]>>>;
    1 => start;
  }else{
    Math.random2(0, 100) => int prob1;
    Math.random2(0, 100) => int prob2;
    if(prob1 >= 80 && jump != 1){
      if(prob2 >= 50 && prevInterval[0] <= maxnote){
        <<<"Step up">>>;
        prevInterval[0] + grSekunde => currentInterval[0];
      } else if(prob2 < 50 || prevInterval[0] > maxnote){
        <<<"Step down">>>;
        prevInterval[0] - grSekunde => currentInterval[0];
      }
    } else{
      1 => jump;
      if(prob2 >= 70){
        if(prob2 > 80 || prevInterval[0] < minnote){
          <<<"Jump of a third up">>>;
          prevInterval[0] + grTerz => currentInterval[0];
        } else if (prob2 < 80 || prevInterval[0] > maxnote){
          <<<"Jump of a third down">>>;
          prevInterval[0] - grTerz => currentInterval[0];
        }
      } else if(prob2 > 40){
        if(prob2 > 55 || prevInterval[0] < minnote){
          <<<"Jump of a lower sixth up">>>;
          prevInterval[0] + klSexte => currentInterval[0];
        } else if(prob2 < 55 || prevInterval[0] > 80){
          <<<"Jump of a lower sixth down">>>;
          prevInterval[0] - klSexte => currentInterval[0];
        }
      }
    }
  }
    if(isPerfect == 0){
      <<< "Call getPerfectInterval">>>;
      getPerfectInterval(perfectCons.size()) => tempInterval;
      if(tempInterval == prime){
        <<<"Prime">>>;
        quinte => tempInterval;
      }
      <<<"Calculate new Interval">>>;
      currentInterval[0]+ tempInterval => currentInterval[1];
      <<<"Send notes to the oscillator">>>;
      Std.mtof(currentInterval[0]) => voice1.freq;
      Std.mtof(currentInterval[1]) => voice2.freq;
      currentInterval[0] => prevInterval[0];
      currentInterval[1] => prevInterval[1];
    
      <<<"Switch to imPerfect">>>;
      1 => isPerfect;
      <<< currentInterval[0], currentInterval[1] >>>;
    } else{
      <<<"Call getImperfectInterval">>>;
      getImperfectInterval(imperfectCons.size()) => tempInterval;

      <<<"Calculate new Interval">>>;
      currentInterval[0] + tempInterval => currentInterval[1];
      <<<"Send notes to the oscillator">>>;
      Std.mtof(currentInterval[0]) => voice1.freq;
      Std.mtof(currentInterval[1]) => voice2.freq;
      currentInterval[0] => prevInterval[0];
      currentInterval[1] => prevInterval[1];
      <<<"Switch to Perfect INterval">>>;
      0 => isPerfect;
      <<< currentInterval[0], currentInterval[1] >>>;
    }
  
  notenwerte[Math.random2(0, notenwerte.size()-1)] => now;
    (ctr + 1) % 8 => ctr;
}

}

spork ~ run();

MidiIn midi;

if (!midi.open(0)) me.exit();
<<< "MIDI input:", midi.num(), midi.name() >>>;

while (stop == 0) {
    // wait for MIDI input
    midi => now;
    // process received MIDI messages
    MidiMsg msg;
    while (midi.recv(msg))  {
        msg.data1 & 0xf0 => int status; // status
        msg.data1 & 0x0f => int chan; // MIDI channel
        msg.data2 => int num; // 1st data byte / note number
        msg.data3 => int val; // 2nd data byte / velocity
        if (status == 0xb0 && num == 1) {
            val / 127.0 $ int => maxnote;
            <<< "maxnote:", maxnote >>>;
        } else if ((status == 0xb0 || num == 8) && val > 0) {
            1 => stop;
        } else {
            <<< status, chan, num, val >>>;
        }
    }
}

4::second => now;
<<< "EXIT" >>>;

/* 
Notenlisten mit Gewichtungen; Präferenzregeln

*/
