<<<"Start">>>;
TriOsc osc1 => dac;
TriOsc osc2 => dac;

1::second => dur beat;

0 => int prime;
1 => int klSek;
2 => int grSek;
3 => int klTerz;
4 => int grTerz;
5 => int quarte;
6 => int tritonus;
7 => int quinte;
8 => int klSext;
9 => int grSext;
10 => int klSept;
11 => int grSept;
12 => int oktave;
[prime, quarte, quinte, oktave] @=> int perfectCons[]; // Länge = 4; Perfekte Konsonanzen
[klTerz, grTerz, klSext, grSext] @=> int imperfectCons[]; // Länge = 4; Imperfekte Konsonanzen

0 => int start;
int frequenzy1;
int frequenzy2;

int interval;
int prev[2];
1 => int isImperfect;
0 => int isPerfect;
fun int getPerfectInterval(int n){
    return perfectCons[Math.random2(0,n-1)];
}

fun int getImperfectInterval(int n){
    return imperfectCons[Math.random2(0,n-1)];
}

fun void perfectInterval(int interval){
    for (0 => int i; i < perfectCons.size(); i++){
        if(interval == perfectCons[i]){
            0 => isPerfect;
        } else{
            1 => isPerfect;
        }
    }
}

fun void imperfectInterval(int interval){
    for(0 => int i; i < imperfectCons.size(); i++){
        if(interval == imperfectCons[i]){
            0 => isImperfect;
        }else{
            1 => isImperfect;
        }
    }
}

fun void saveInterval(int i1, int i2){
    i1 => prev[0];
    i2 => prev[1];
}
while(true)
{
    <<<"Start the music">>>;
    if(start == 0 || isImperfect == 0){
        Math.random2(60, 72) => frequenzy1;
        getPerfectInterval(perfectCons.size()) => interval;
        frequenzy1 + interval => frequenzy2;
        Std.mtof(frequenzy1) => osc1.freq;
        Std.mtof(frequenzy2) => osc2.freq;
        saveInterval(frequenzy1, frequenzy2);
        <<< prev[0], prev[1] >>>;
    }
    perfectInterval(interval);
    imperfectInterval(interval);

    if(start == 1 || isPerfect == 0){
        Math.random2(60, 72) => frequenzy1;
        Std.mtof(frequenzy1) => osc1.freq;
        getImperfectInterval(imperfectCons.size()) => interval;
        frequenzy1 + interval => frequenzy2;
        Std.mtof(frequenzy2) => osc2.freq;
        saveInterval(frequenzy1, frequenzy2);
        <<< prev[0], prev[1] >>>;
    }
    perfectInterval(interval);
    imperfectInterval(interval);
    beat=>now;
}