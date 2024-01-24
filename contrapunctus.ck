SinOsc voice1 => dac;
SinOsc voice2 => dac;

//gain auf 0.5 setzen, damit´s nicht zu laut wird.
0.5 => voice1.gain;
0.5 => voice2.gain;

// Initialisierung Rhythmus
// 60 BPM = 1 BPS
// 80 BPM = 80/60 = 1,3
// ms = 1000/BPS (1000ms = 1s)
// 1000/1,3 ~ 770ms
// Ganze Note bei 80 BPM = 3080 ms
3080::ms => dur ganze; // 80 BPM
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

int f1;
int f2;

int prevInterval[2];
int currentInterval[2];
int nextInterval[2];

1 => int isImperfect;
0 => int isPerfect;

fun int getPerfectInterval(int n){
  return perfectCons[Math.random2(0,n-1)];
}

fun int getImperfectInterval(int n){
  return imperfectCons[Math.random2(0,n-1)];
}


while(true){
  <<< "Start the Music" >>>;
  int tempInterval;
  if(isPerfect){
    Math.random2(60, 72) => f1;
    f1 => currentInterval[0];
    <<< "Call getPerfectInterval">>>;
    getPerfectInterval(perfectCons.size()) => tempInterval;

    if(tempInterval == prime){
      <<<"Prime">>>;
      quinte => tempInterval;
    }
    <<<"Calculate new Interval">>>;
    f1 + tempInterval => f2 => currentInterval[1];
    <<<"Send notes to the oscillator">>>;
    Std.mtof(currentInterval[0]) => voice1.freq;
    Std.mtof(currentInterval[1]) => voice2.freq;
    currentInterval[0] => prevInterval[0];
    currentInterval[1] => prevInterval[1];
    
    <<<"Switch to imPerfect">>>;
    isPerfectInterval(tempInterval) => isPerfect;
    isImperfectInterval(tempInterval) => isImperfect;

    <<< currentInterval[0], currentInterval[1] >>>;
  }

  ganze => now;
  if(isImperfect){
    Math.random2(60, 72) => f1;
    f1 => currentInterval[0];
    <<<"Call getImperfectInterval">>>;
    getImperfectInterval(imperfectCons.size()) => tempInterval;

    <<<"Calculate new Interval">>>;
    f1 + tempInterval => f2 => currentInterval[1];
    <<<"Send notes to the oscillator">>>;
    Std.mtof(currentInterval[0]) => voice1.freq;
    Std.mtof(currentInterval[1]) => voice2.freq;
    currentInterval[0] => prevInterval[0];
    currentInterval[1] => prevInterval[1];
    <<<"Switch to Perfect INterval">>>;
    isPerfectInterval(tempInterval) => isPerfect;
    isImperfectInterval(tempInterval) => isImperfect;
    <<< currentInterval[0], currentInterval[1] >>>;
  }
  viertel => now;
}
