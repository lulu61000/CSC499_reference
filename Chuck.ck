SinOsc osc => ADSR env => dac => WvOut waveOut => blackhole;
"test.wav" => waveOut.wavFilename;
(1::ms, 100::ms, 0, 1::ms) => env.set;
5 => int Max_Colunm; 

FileIO io_csv;
io_csv.open("datam.csv", FileIO.READ);

1::second => dur beat;
78 => int offset;

0.5 => float defult_vol;
200 => float defult_freq;
16 => float defult_duration_div;

// 5 => int row_picked; 1D picking uncomment this

// case for easier file read
fun string[] find_col_raw(FileIO io){
    string Column[0];
    StringTokenizer strtok;
    io.readLine() => string raw_line;
    strtok.set(raw_line);
    while(strtok.more())
        {
        Column <<  strtok.next();
        }
    return Column;
}
// case for csv file read
fun string[][] find_col_csv(FileIO io){
    0 => int count;
    string Column[0];
    string Table[0][0];
    StringTokenizer strtok;
    io.readLine() => string raw_line;
    raw_line.replace(" ","@");
    raw_line.replace(","," ");
    strtok.set(raw_line);
    while(strtok.more())
        {
        strtok.next() => string with_at;
        with_at.replace("@"," ");
        Column << with_at;
        1 +=> count;
        }
    Table << Column;
    return Table;
}

// Get column names
find_col_csv(io_csv) @=> string Table[][];
<<<Table[0].cap()>>>;
// Get mapping from column name to attributes
fun int find_col_index(string find, string search[]){
    for (0 => int i; i < search.cap() ;i++){
        <<<find,search[i]>>>;
        if (find == search[i]){
            return i;
        }
    }
    return -1;
}

-1 => int freq_col;
-1 => int vol_col;
-1 => int duration_col;

for (0 => int i; i < Max_Colunm ;i++){
    while(me.arg(i) != ""){
        StringTokenizer strtok;
        me.arg(i) => string pair;
        pair.replace("->"," ");
        strtok.set(pair);
        strtok.next()=> string map_from;
        map_from.replace("_"," ");
        strtok.next() => string map_to;
        if (map_to.find("freq")!=-1){
            if(find_col_index(map_from,Table[0]) != -1){
                find_col_index(map_from,Table[0]) => freq_col;
            }
            else{
                <<<"ERROR_no_Freq_mapping">>>;
            }
        }
        else if (map_to.find("vol")!=-1){
            if(find_col_index(map_from,Table[0]) != -1){
                find_col_index(map_from,Table[0]) => vol_col;
            }
            else{
                <<<"ERROR_no_Vol_mapping">>>;
            }
        }
        else if (map_to.find("duration")!=-1){
            if(find_col_index(map_from,Table[0]) != -1){
                find_col_index(map_from,Table[0]) => duration_col;
            }
            else{
                <<<"ERROR_no_Duration_mapping">>>;
            }
        }
        else{
            <<<"ERROR_mapping">>>;
        }
        1 +=> i;
    }
    break;
} 
// reading rest of file

StringTokenizer strtok;
0 => int line_counter;
while(io_csv.eof() == false){
        io_csv.readLine() => string raw_line;
        raw_line.replace(","," ");
        strtok.set(raw_line);
        string line[0];
        while(strtok.more())
        {
        line << strtok.next();
        }
        1 +=> line_counter;
        Table << line;
    }
fun string[] get_all(string command){ // get info in from of mapto[0]mapfrom[1]min[2]max[3]
    string result[0];
    StringTokenizer strtok;
    command.replace("="," ");
    strtok.set(command);
    while(strtok.more()){
        strtok.next() => string raw_line;
        if (raw_line.find("@min")>0){
            raw_line.replace("@min","");
            result << raw_line;
        }
        else if (raw_line.find("@max")>0){
            raw_line.replace("@max","");
            result << raw_line;
        }
        else{
            result << raw_line;
        }
    }
    return result;
}
fun void categorical_note_mapping(string command, string categorical_mappings[][], string Table[][]){
    command => string raw_line;
    <<<raw_line>>>;
    raw_line.replace(" ","_");
    raw_line.replace(","," ");
    StringTokenizer strtok;
    strtok.set(raw_line);
    while(strtok.more())
        {
            StringTokenizer strtok_low;
            strtok.next() => string raw_line_low;
            if (raw_line_low.find("=@")>0){
                <<<"case=@",raw_line_low>>>;
                
            }
            else if (raw_line_low.find("@")>0){
                get_all(raw_line_low)[0] => string audio_attri;
                get_all(raw_line_low)[1] => string data_attri;
                get_all(raw_line_low)[2].toFloat() => float min;
                get_all(raw_line_low)[3].toFloat() => float max;
                <<<"case@",audio_attri,data_attri,min,max>>>;
            }
            else{
                <<<"case=",raw_line_low>>>;
            }
            // strtok_low.set(raw_line_low);
            // while(strtok_low.more())
            // {
            //     strtok_low.next() => string raw_line_low_low;
            //     <<<raw_line_low_low>>>;
            // }
        }
}




fun void note_mapping(string command, string Table[][]){
    command => string raw_line;
    <<<raw_line>>>;
    raw_line.replace(" ","_");
    raw_line.replace(","," ");
    StringTokenizer strtok;
    strtok.set(raw_line);
    while(strtok.more())
        {
            StringTokenizer strtok_low;
            strtok.next() => string raw_line_low;
            if (raw_line_low.find("=@")>0){
                <<<"case=@",raw_line_low>>>;
            }
            else if (raw_line_low.find("@")>0){
                get_all(raw_line_low)[0] => string audio_attri;
                get_all(raw_line_low)[1] => string data_attri;
                get_all(raw_line_low)[2].toFloat() => float min;
                get_all(raw_line_low)[3].toFloat() => float max;
                <<<"case@",audio_attri,data_attri,min,max>>>;
            }
            else{
                <<<"case=",raw_line_low>>>;
            }
            // strtok_low.set(raw_line_low);
            // while(strtok_low.more())
            // {
            //     strtok_low.next() => string raw_line_low_low;
            //     <<<raw_line_low_low>>>;
            // }
        }
}


//note_mapping("dur=100,pitch=SP500@min=100@max=300,timber=Real Price,volume=1",Table);



// fun void categorical_note_mapping(){
//     false
// }
string categorical_mappings[20][20]; // map 0 to 1, 2 to 3, 4 to 5 for different lists
categorical_mappings[0] << "Earnings";
categorical_mappings[0] << "piano";
categorical_mappings[0] << "Date";
categorical_mappings[0] << "flute";
categorical_mappings[0] << "SP500";
categorical_mappings[0] << "clannet";
categorical_note_mapping("dur=100,pitch=SP500@min=100@max=300,timber=@1,volume=1",categorical_mappings,Table);




//play the file

play(line_counter);
fun void play(int line_counter){
        for (1 => int i; i < line_counter+1 ;i++){
            defult_freq => float playable_freq;
            defult_vol => float playable_vol;
            defult_duration_div => float playable_duration_div;
            if (freq_col != -1){
                Table[i][freq_col].toFloat() => playable_freq;
            }
            if (vol_col != -1){
                Table[i][vol_col].toFloat() => playable_vol;
            }
            if (duration_col != -1){
                Table[i][duration_col].toFloat() => playable_duration_div;
            }
            <<<playable_freq,playable_vol,playable_duration_div>>>;
            playable_freq + offset => Std.mtof => osc.freq;
            playable_vol/2 => osc.gain;
            1 => env.keyOn;
            beat/playable_duration_div => now;
        }
        0 => osc.freq;
        defult_vol => osc.gain;
        1 => env.keyOn;
        beat => now;
    }
// play(line_counter);
// fun void play(int line_counter){
//     while(true){
//         for (1 => int i; i < line_counter+1 ;i++){
//             defult_freq => float playable_freq;
//             defult_vol => float playable_vol;
//             defult_duration_div => float playable_duration_div;
//             if (freq_col != -1){
//                 Table[i][freq_col].toFloat() => playable_freq;
//             }
//             if (vol_col != -1){
//                 Table[i][vol_col].toFloat() => playable_vol;
//             }
//             if (duration_col != -1){
//                 Table[i][duration_col].toFloat() => playable_duration_div;
//             }
//             <<<playable_freq,playable_vol,playable_duration_div>>>;
//             playable_freq + offset => Std.mtof => osc.freq;
//             playable_vol/2 => osc.gain;
//             1 => env.keyOn;
//             beat/playable_duration_div => now;
//         }
//         0 => osc.freq;
//         defult_vol => osc.gain;
//         1 => env.keyOn;
//         beat => now;
//     }
// }