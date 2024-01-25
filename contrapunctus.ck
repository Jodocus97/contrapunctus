TriOsc voice1 => dac;
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

int prevInterval[2];
int currentInterval[2];
//int nextInterval[2];

1 => int isImperfect;
0 => int isPerfect;

0 => int jump;
0 => int start;
fun int getPerfectInterval(int n){
  return perfectCons[Math.random2(0,n-1)];
}

fun int getImperfectInterval(int n){
  return imperfectCons[Math.random2(0,n-1)];
}

while(true){
  <<< "Start the Music" >>>;
  int tempInterval;
  if(start == 0){
    <<<"initialise first tone">>>;
    Math.random2(60, 72) => currentInterval[0];
    <<<"First tone is: ", currentInterval[0]>>>;
    1 => start;
  }else{
    Math.random2(0, 100) => int prob1;
    Math.random2(0, 100) => int prob2;
    if(prob1 >= 80 && jump != 1){
      if(prob2 >= 50 && prevInterval[0] <= 90){
        <<<"Step up">>>;
        prevInterval[0] + grSekunde => currentInterval[0];
      } else if(prob2 < 50 || prevInterval[0] > 80){
        <<<"Step down">>>;
        prevInterval[0] - grSekunde => currentInterval[0];
      }
    } else{
      1 => jump;
      if(prob2 >= 70){
        if(prob2 > 80 || prevInterval[0] < 40){
          <<<"Jump of a third up">>>;
          prevInterval[0] + grTerz => currentInterval[0];
        } else if (prob2 < 80 || prevInterval[0] > 80){
          <<<"Jump of a third down">>>;
          prevInterval[0] - grTerz => currentInterval[0];
        }
      } else if(prob2 > 40){
        if(prob2 > 55 || prevInterval[0] < 40){
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
}

/* 
Notenlisten mit Gewichtungen; Präferenzregeln

*/
