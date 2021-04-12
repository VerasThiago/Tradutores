int main(int n){
    int x;
    x = 10 + 3.141516 || 14 < 3;
}

// (float)(10 + 3 / 4) + 3.0

 
//                   +
//           10             3.0



//   10 + 3 / 4 + 3.0

//   |   |   |   ├─ expression_additive  ── [7:20] additive operator : (float)INT + FLOAT
//   |   |   |   |   |   ├─ expression_additive  ── [7:12] additive operator : INT + INT
//   |   |   |   |   |   |   ├─ const  ── [7:9] INT : 10
//   |   |   |   |   |   |   ├─ expression_multiplicative  ── [7:16] multiplicative operator : INT / INT
//   |   |   |   |   |   |   |   ├─ const  ── [7:14] INT : 3
//   |   |   |   |   |   |   |   ├─ const  ── [7:18] INT : 4
//   |   |   |   |   |   ├─ const  ── [7:22] FLOAT : 3.0

