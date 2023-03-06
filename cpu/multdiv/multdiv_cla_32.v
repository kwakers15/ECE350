module multdiv_cla_32(data_result, Cout, data_operandA, data_operandB, Cin);
  input [31:0] data_operandA, data_operandB;
  input Cin;
  output [31:0] data_result;
  output Cout;

  // start of 7-0 CLA block
  wire g7, g6, g5, g4, g3, g2, g1, g0, p7, p6, p5, p4, p3, p2, p1, p0;
  and g7_and(g7, data_operandA[7], data_operandB[7]);
  and g6_and(g6, data_operandA[6], data_operandB[6]);
  and g5_and(g5, data_operandA[5], data_operandB[5]);
  and g4_and(g4, data_operandA[4], data_operandB[4]);
  and g3_and(g3, data_operandA[3], data_operandB[3]);
  and g2_and(g2, data_operandA[2], data_operandB[2]);
  and g1_and(g1, data_operandA[1], data_operandB[1]);
  and g0_and(g0, data_operandA[0], data_operandB[0]);
  or p7_or(p7, data_operandA[7], data_operandB[7]);
  or p6_or(p6, data_operandA[6], data_operandB[6]);
  or p5_or(p5, data_operandA[5], data_operandB[5]);
  or p4_or(p4, data_operandA[4], data_operandB[4]);
  or p3_or(p3, data_operandA[3], data_operandB[3]);
  or p2_or(p2, data_operandA[2], data_operandB[2]);
  or p1_or(p1, data_operandA[1], data_operandB[1]);
  or p0_or(p0, data_operandA[0], data_operandB[0]);

  wire c8, c7, c6, c5, c4, c3, c2, c1;

  // c1 calculations
  wire p0c0;

  and p0c0_and(p0c0, p0, Cin);
  or c1_or(c1, g0, p0c0);

  // c2 calculations
  wire p1g0, p1p0c0;

  and p1g0_and(p1g0, p1, g0);
  and p1p0c0_and(p1p0c0, p1, p0, Cin);
  or c2_or(c2, g1, p1g0, p1p0c0);

  // c3 calculations
  wire p2g1, p2p1g0, p2p1p0c0;

  and p2g1_and(p2g1, p2, g1);
  and p2p1g0_and(p2p1g0, p2, p1, g0);
  and p2p1p0c0_and(p2p1p0c0, p2, p1, p0, Cin);
  or c3_or(c3, g2, p2g1, p2p1g0, p2p1p0c0);

  // c4 calculations
  wire p3g2, p3p2g1, p3p2p1g0, p3p2p1p0c0;

  and p3g2_and(p3g2, p3, g2);
  and p3p2g1_and(p3p2g1, p3, p2, g1);
  and p3p2p1g0_and(p3p2p1g0, p3, p2, p1, g0);
  and p3p2p1p0c0_and(p3p2p1p0c0, p3, p2, p1, p0, Cin);
  or c4_or(c4, g3, p3g2, p3p2g1, p3p2p1g0, p3p2p1p0c0);

  // c5 calculations
  wire p4g3, p4p3g2, p4p3p2g1, p4p3p2p1g0, p4p3p2p1p0c0;

  and p4g3_and(p4g3, p4, g3);
  and p4p3g2_and(p4p3g2, p4, p3, g2);
  and p4p3p2g1_and(p4p3p2g1, p4, p3, p2, g1);
  and p4p3p2p1g0_and(p4p3p2p1g0, p4, p3, p2, p1, g0);
  and p4p3p2p1p0c0_and(p4p3p2p1p0c0, p4, p3, p2, p1, p0, Cin);
  or c5_or(c5, g4, p4g3, p4p3g2, p4p3p2g1, p4p3p2p1g0, p4p3p2p1p0c0);

  // c6 calculations
  wire p5g4, p5p4g3, p5p4p3g2, p5p4p3p2g1, p5p4p3p2p1g0, p5p4p3p2p1p0c0;

  and p5g4_and(p5g4, p5, g4);
  and p5p4g3_and(p5p4g3, p5, p4, g3);
  and p5p4p3g2_and(p5p4p3g2, p5, p4, p3, g2);
  and p5p4p3p2g1_and(p5p4p3p2g1, p5, p4, p3, p2, g1);
  and p5p4p3p2p1g0_and(p5p4p3p2p1g0, p5, p4, p3, p2, p1, g0);
  and p5p4p3p2p1p0c0_and(p5p4p3p2p1p0c0, p5, p4, p3, p2, p1, p0, Cin);
  or c6_or(c6, g5, p5g4, p5p4g3, p5p4p3g2, p5p4p3p2g1, p5p4p3p2p1g0, p5p4p3p2p1p0c0);

  // c7 calculations
  wire p6g5, p6p5g4, p6p5p4g3, p6p5p4p3g2, p6p5p4p3p2g1, p6p5p4p3p2p1g0, p6p5p4p3p2p1p0c0;

  and p6g5_and(p6g5, p6, g5);
  and p6p5g4_and(p6p5g4, p6, p5, g4);
  and p6p5p4g3_and(p6p5p4g3, p6, p5, p4, g3);
  and p6p5p4p3g2_and(p6p5p4p3g2, p6, p5, p4, p3, g2);
  and p6p5p4p3p2g1_and(p6p5p4p3p2g1, p6, p5, p4, p3, p2, g1);
  and p6p5p4p3p2p1g0_and(p6p5p4p3p2p1g0, p6, p5, p4, p3, p2, p1, g0);
  and p6p5p4p3p2p1p0c0_and(p6p5p4p3p2p1p0c0, p6, p5, p4, p3, p2, p1, p0, Cin);
  or c7_or(c7, g6, p6g5, p6p5g4, p6p5p4g3, p6p5p4p3g2, p6p5p4p3p2g1, p6p5p4p3p2p1g0, p6p5p4p3p2p1p0c0);

  // G0, P0 calculations
  wire p7g6, p7p6g5, p7p6p5g4, p7p6p5p4g3, p7p6p5p4p3g2, p7p6p5p4p3p2g1, p7p6p5p4p3p2p1g0;

  and p7g6_and(p7g6, p7, g6);
  and p7p6g5_and(p7p6g5, p7, p6, g5);
  and p7p6p5g4_and(p7p6p5g4, p7, p6, p5, g4);
  and p7p6p5p4g3_and(p7p6p5p4g3, p7, p6, p5, p4, g3);
  and p7p6p5p4p3g2_and(p7p6p5p4p3g2, p7, p6, p5, p4, p3, g2);
  and p7p6p5p4p3p2g1_and(p7p6p5p4p3p2g1, p7, p6, p5, p4, p3, p2, g1);
  and p7p6p5p4p3p2p1g0_and(p7p6p5p4p3p2p1g0, p7, p6, p5, p4, p3, p2, p1, g0);

  wire G0, P0;
  or G0_or(G0, g7, p7g6, p7p6g5, p7p6p5g4, p7p6p5p4g3, p7p6p5p4p3g2, p7p6p5p4p3p2g1, p7p6p5p4p3p2p1g0);
  and P0_and(P0, p7, p6, p5, p4, p3, p2, p1, p0);

  // c8 calculation
  wire P0c0;

  and P0c0_and(P0c0, P0, Cin);
  or c8_or(c8, G0, P0c0);

  // s7-s0 calculations
  xor s0(data_result[0], data_operandA[0], data_operandB[0], Cin);
  xor s1(data_result[1], data_operandA[1], data_operandB[1], c1);
  xor s2(data_result[2], data_operandA[2], data_operandB[2], c2);
  xor s3(data_result[3], data_operandA[3], data_operandB[3], c3);
  xor s4(data_result[4], data_operandA[4], data_operandB[4], c4);
  xor s5(data_result[5], data_operandA[5], data_operandB[5], c5);
  xor s6(data_result[6], data_operandA[6], data_operandB[6], c6);
  xor s7(data_result[7], data_operandA[7], data_operandB[7], c7);

  // start of 15-8 CLA block
  wire g15, g14, g13, g12, g11, g10, g9, g8, p15, p14, p13, p12, p11, p10, p9, p8;
  and g15_and(g15, data_operandA[15], data_operandB[15]);
  and g14_and(g14, data_operandA[14], data_operandB[14]);
  and g13_and(g13, data_operandA[13], data_operandB[13]);
  and g12_and(g12, data_operandA[12], data_operandB[12]);
  and g11_and(g11, data_operandA[11], data_operandB[11]);
  and g10_and(g10, data_operandA[10], data_operandB[10]);
  and g9_and(g9, data_operandA[9], data_operandB[9]);
  and g8_and(g8, data_operandA[8], data_operandB[8]);
  or p15_or(p15, data_operandA[15], data_operandB[15]);
  or p14_or(p14, data_operandA[14], data_operandB[14]);
  or p13_or(p13, data_operandA[13], data_operandB[13]);
  or p12_or(p12, data_operandA[12], data_operandB[12]);
  or p11_or(p11, data_operandA[11], data_operandB[11]);
  or p10_or(p10, data_operandA[10], data_operandB[10]);
  or p9_or(p9, data_operandA[9], data_operandB[9]);
  or p8_or(p8, data_operandA[8], data_operandB[8]);

  wire c16, c15, c14, c13, c12, c11, c10, c9;

  // c9 calculations
  wire p8c8;

  and p8c8_and(p8c8, p8, c8);
  or c9_or(c9, g8, p8c8);

  // c10 calculations
  wire p9g8, p9p8c8;

  and p9g8_and(p9g8, p9, g8);
  and p9p8c8_and(p9p8c8, p9, p8, c8);
  or c10_or(c10, g9, p9g8, p9p8c8);

  // c11 calculations
  wire p10g9, p10p9g8, p10p9p8c8;

  and p10g9_and(p10g9, p10, g9);
  and p10p9g8_and(p10p9g8, p10, p9, g8);
  and p10p9p8c8_and(p10p9p8c8, p10, p9, p8, c8);
  or c11_or(c11, g10, p10g9, p10p9g8, p10p9p8c8);

  // c12 calculations
  wire p11g10, p11p10g9, p11p10p9g8, p11p10p9p8c8;

  and p11g10_and(p11g10, p11, g10);
  and p11p10g9_and(p11p10g9, p11, p10, g9);
  and p11p10p9g8_and(p11p10p9g8, p11, p10, p9, g8);
  and p11p10p9p8c8_and(p11p10p9p8c8, p11, p10, p9, p8, c8);
  or c12_or(c12, g11, p11g10, p11p10g9, p11p10p9g8, p11p10p9p8c8);

  // c13 calculations
  wire p12g11, p12p11g10, p12p11p10g9, p12p11p10p9g8, p12p11p10p9p8c8;

  and p12g11_and(p12g11, p12, g11);
  and p12p11g10_and(p12p11g10, p12, p11, g10);
  and p12p11p10g9_and(p12p11p10g9, p12, p11, p10, g9);
  and p12p11p10p9g8_and(p12p11p10p9g8, p12, p11, p10, p9, g8);
  and p12p11p10p9p8c8_and(p12p11p10p9p8c8, p12, p11, p10, p9, p8, c8);
  or c13_or(c13, g12, p12g11, p12p11g10, p12p11p10g9, p12p11p10p9g8, p12p11p10p9p8c8);

  // c14 calculations
  wire p13g12, p13p12g11, p13p12p11g10, p13p12p11p10g9, p13p12p11p10p9g8, p13p12p11p10p9p8c8;

  and p13g12_and(p13g12, p13, g12);
  and p13p12g11_and(p13p12g11, p13, p12, g11);
  and p13p12p11g10_and(p13p12p11g10, p13, p12, p11, g10);
  and p13p12p11p10g9_and(p13p12p11p10g9, p13, p12, p11, p10, g9);
  and p13p12p11p10p9g8_and(p13p12p11p10p9g8, p13, p12, p11, p10, p9, g8);
  and p13p12p11p10p9p8c8_and(p13p12p11p10p9p8c8, p13, p12, p11, p10, p9, p8, c8);
  or c14_or(c14, g13, p13g12, p13p12g11, p13p12p11g10, p13p12p11p10g9, p13p12p11p10p9g8, p13p12p11p10p9p8c8);

  // c15 calculations
  wire p14g13, p14p13g12, p14p13p12g11, p14p13p12p11g10, p14p13p12p11p10g9, p14p13p12p11p10p9g8, p14p13p12p11p10p9p8c8;

  and p14g13_and(p14g13, p14, g13);
  and p14p13g12_and(p14p13g12, p14, p13, g12);
  and p14p13p12g11_and(p14p13p12g11, p14, p13, p12, g11);
  and p14p13p12p11g10_and(p14p13p12p11g10, p14, p13, p12, p11, g10);
  and p14p13p12p11p10g9_and(p14p13p12p11p10g9, p14, p13, p12, p11, p10, g9);
  and p14p13p12p11p10p9g8_and(p14p13p12p11p10p9g8, p14, p13, p12, p11, p10, p9, g8);
  and p14p13p12p11p10p9p8c8_and(p14p13p12p11p10p9p8c8, p14, p13, p12, p11, p10, p9, p8, c8);
  or c15_or(c15, g14, p14g13, p14p13g12, p14p13p12g11, p14p13p12p11g10, p14p13p12p11p10g9, p14p13p12p11p10p9g8, p14p13p12p11p10p9p8c8);

  // G1, P1 calculations
  wire p15g14, p15p14g13, p15p14p13g12, p15p14p13p12g11, p15p14p13p12p11g10, p15p14p13p12p11p10g9, p15p14p13p12p11p10p9g8;

  and p15g14_and(p15g14, p15, g14);
  and p15p14g13_and(p15p14g13, p15, p14, g13);
  and p15p14p13g12_and(p15p14p13g12, p15, p14, p13, g12);
  and p15p14p13p12g11_and(p15p14p13p12g11, p15, p14, p13, p12, g11);
  and p15p14p13p12p11g10_and(p15p14p13p12p11g10, p15, p14, p13, p12, p11, g10);
  and p15p14p13p12p11p10g9_and(p15p14p13p12p11p10g9, p15, p14, p13, p12, p11, p10, g9);
  and p15p14p13p12p11p10p9g8_and(p15p14p13p12p11p10p9g8, p15, p14, p13, p12, p11, p10, p9, g8);

  wire G1, P1;
  or G1_or(G1, g15, p15g14, p15p14g13, p15p14p13g12, p15p14p13p12g11, p15p14p13p12p11g10, p15p14p13p12p11p10g9, p15p14p13p12p11p10p9g8);
  and P1_and(P1, p15, p14, p13, p12, p11, p10, p9, p8);

  // c16 calculation
  wire P1G0, P1P0c0;

  and P1G0_and(P1G0, P1, G0);
  and P1P0c0_and(P1P0c0, P1, P0, Cin);
  or c16_or(c16, G1, P1G0, P1P0c0);

  // s15-s8 calculations
  xor s8(data_result[8], data_operandA[8], data_operandB[8], c8);
  xor s9(data_result[9], data_operandA[9], data_operandB[9], c9);
  xor s10(data_result[10], data_operandA[10], data_operandB[10], c10);
  xor s11(data_result[11], data_operandA[11], data_operandB[11], c11);
  xor s12(data_result[12], data_operandA[12], data_operandB[12], c12);
  xor s13(data_result[13], data_operandA[13], data_operandB[13], c13);
  xor s14(data_result[14], data_operandA[14], data_operandB[14], c14);
  xor s15(data_result[15], data_operandA[15], data_operandB[15], c15);

  // start of 23-16 CLA block
  wire g23, g22, g21, g20, g19, g18, g17, g16, p23, p22, p21, p20, p19, p18, p17, p16;
  and g23_and(g23, data_operandA[23], data_operandB[23]);
  and g22_and(g22, data_operandA[22], data_operandB[22]);
  and g21_and(g21, data_operandA[21], data_operandB[21]);
  and g20_and(g20, data_operandA[20], data_operandB[20]);
  and g19_and(g19, data_operandA[19], data_operandB[19]);
  and g18_and(g18, data_operandA[18], data_operandB[18]);
  and g17_and(g17, data_operandA[17], data_operandB[17]);
  and g16_and(g16, data_operandA[16], data_operandB[16]);
  or p23_or(p23, data_operandA[23], data_operandB[23]);
  or p22_or(p22, data_operandA[22], data_operandB[22]);
  or p21_or(p21, data_operandA[21], data_operandB[21]);
  or p20_or(p20, data_operandA[20], data_operandB[20]);
  or p19_or(p19, data_operandA[19], data_operandB[19]);
  or p18_or(p18, data_operandA[18], data_operandB[18]);
  or p17_or(p17, data_operandA[17], data_operandB[17]);
  or p16_or(p16, data_operandA[16], data_operandB[16]);

  wire c24, c23, c22, c21, c20, c19, c18, c17;

  // c17 calculations
  wire p16c16;

  and p16c16_and(p16c16, p16, c16);
  or c17_or(c17, g16, p16c16);

  // c18 calculations
  wire p17g16, p17p16c16;

  and p17g16_and(p17g16, p17, g16);
  and p17p16c16_and(p17p16c16, p17, p16, c16);
  or c18_or(c18, g17, p17g16, p17p16c16);

  // c19 calculations
  wire p18g17, p18p17g16, p18p17p16c16;

  and p18g17_and(p18g17, p18, g17);
  and p18p17g16_and(p18p17g16, p18, p17, g16);
  and p18p17p16c16_and(p18p17p16c16, p18, p17, p16, c16);
  or c19_or(c19, g18, p18g17, p18p17g16, p18p17p16c16);

  // c20 calculations
  wire p19g18, p19p18g17, p19p18p17g16, p19p18p17p16c16;

  and p19g18_and(p19g18, p19, g18);
  and p19p18g17_and(p19p18g17, p19, p18, g17);
  and p19p18p17g16_and(p19p18p17g16, p19, p18, p17, g16);
  and p19p18p17p16c16_and(p19p18p17p16c16, p19, p18, p17, p16, c16);
  or c20_or(c20, g19, p19g18, p19p18g17, p19p18p17g16, p19p18p17p16c16);

  // c21 calculations
  wire p20g19, p20p19g18, p20p19p18g17, p20p19p18p17g16, p20p19p18p17p16c16;

  and p20g19_and(p20g19, p20, g19);
  and p20p19g18_and(p20p19g18, p20, p19, g18);
  and p20p19p18g17_and(p20p19p18g17, p20, p19, p18, g17);
  and p20p19p18p17g16_and(p20p19p18p17g16, p20, p19, p18, p17, g16);
  and p20p19p18p17p16c16_and(p20p19p18p17p16c16, p20, p19, p18, p17, p16, c16);
  or c21_or(c21, g20, p20g19, p20p19g18, p20p19p18g17, p20p19p18p17g16, p20p19p18p17p16c16);

  // c22 calculations
  wire p21g20, p21p20g19, p21p20p19g18, p21p20p19p18g17, p21p20p19p18p17g16, p21p20p19p18p17p16c16;

  and p21g20_and(p21g20, p21, g20);
  and p21p20g19_and(p21p20g19, p21, p20, g19);
  and p21p20p19g18_and(p21p20p19g18, p21, p20, p19, g18);
  and p21p20p19p18g17_and(p21p20p19p18g17, p21, p20, p19, p18, g17);
  and p21p20p19p18p17g16_and(p21p20p19p18p17g16, p21, p20, p19, p18, p17, g16);
  and p21p20p19p18p17p16c16_and(p21p20p19p18p17p16c16, p21, p20, p19, p18, p17, p16, c16);
  or c22_or(c22, g21, p21g20, p21p20g19, p21p20p19g18, p21p20p19p18g17, p21p20p19p18p17g16, p21p20p19p18p17p16c16);

  // c23 calculations
  wire p22g21, p22p21g20, p22p21p20g19, p22p21p20p19g18, p22p21p20p19p18g17, p22p21p20p19p18p17g16, p22p21p20p19p18p17p16c16;

  and p22g21_and(p22g21, p22, g21);
  and p22p21g20_and(p22p21g20, p22, p21, g20);
  and p22p21p20g19_and(p22p21p20g19, p22, p21, p20, g19);
  and p22p21p20p19g18_and(p22p21p20p19g18, p22, p21, p20, p19, g18);
  and p22p21p20p19p18g17_and(p22p21p20p19p18g17, p22, p21, p20, p19, p18, g17);
  and p22p21p20p19p18p17g16_and(p22p21p20p19p18p17g16, p22, p21, p20, p19, p18, p17, g16);
  and p22p21p20p19p18p17p16c16_and(p22p21p20p19p18p17p16c16, p22, p21, p20, p19, p18, p17, p16, c16);
  or c23_or(c23, g22, p22g21, p22p21g20, p22p21p20g19, p22p21p20p19g18, p22p21p20p19p18g17, p22p21p20p19p18p17g16, p22p21p20p19p18p17p16c16);

  // G2, P2 calculations
  wire p23g22, p23p22g21, p23p22p21g20, p23p22p21p20g19, p23p22p21p20p19g18, p23p22p21p20p19p18g17, p23p22p21p20p19p18p17g16;

  and p23g22_and(p23g22, p23, g22);
  and p23p22g21_and(p23p22g21, p23, p22, g21);
  and p23p22p21g20_and(p23p22p21g20, p23, p22, p21, g20);
  and p23p22p21p20g19_and(p23p22p21p20g19, p23, p22, p21, p20, g19);
  and p23p22p21p20p19g18_and(p23p22p21p20p19g18, p23, p22, p21, p20, p19, g18);
  and p23p22p21p20p19p18g17_and(p23p22p21p20p19p18g17, p23, p22, p21, p20, p19, p18, g17);
  and p23p22p21p20p19p18p17g16_and(p23p22p21p20p19p18p17g16, p23, p22, p21, p20, p19, p18, p17, g16);

  wire G2, P2;
  or G2_or(G2, g23, p23g22, p23p22g21, p23p22p21g20, p23p22p21p20g19, p23p22p21p20p19g18, p23p22p21p20p19p18g17, p23p22p21p20p19p18p17g16);
  and P2_and(P2, p23, p22, p21, p20, p19, p18, p17, p16);

  // c24 calculation
  wire P2G1, P2P1G0, P2P1P0c0;
  and P2G1_and(P2G1, P2, G1);
  and P2P1G0_and(P2P1G0, P2, P1, G0);
  and P2P1P0c0_and(P2P1P0c0, P2, P1, P0, Cin);
  or c24_or(c24, G2, P2G1, P2P1G0, P2P1P0c0);

  // s23-s16 calculations
  xor s16(data_result[16], data_operandA[16], data_operandB[16], c16);
  xor s17(data_result[17], data_operandA[17], data_operandB[17], c17);
  xor s18(data_result[18], data_operandA[18], data_operandB[18], c18);
  xor s19(data_result[19], data_operandA[19], data_operandB[19], c19);
  xor s20(data_result[20], data_operandA[20], data_operandB[20], c20);
  xor s21(data_result[21], data_operandA[21], data_operandB[21], c21);
  xor s22(data_result[22], data_operandA[22], data_operandB[22], c22);
  xor s23(data_result[23], data_operandA[23], data_operandB[23], c23);


  // start of 31-24 CLA block
  wire g31, g30, g29, g28, g27, g26, g25, g24, p31, p30, p29, p28, p27, p26, p25, p24;
  and g31_and(g31, data_operandA[31], data_operandB[31]);
  and g30_and(g30, data_operandA[30], data_operandB[30]);
  and g29_and(g29, data_operandA[29], data_operandB[29]);
  and g28_and(g28, data_operandA[28], data_operandB[28]);
  and g27_and(g27, data_operandA[27], data_operandB[27]);
  and g26_and(g26, data_operandA[26], data_operandB[26]);
  and g25_and(g25, data_operandA[25], data_operandB[25]);
  and g24_and(g24, data_operandA[24], data_operandB[24]);
  or p31_or(p31, data_operandA[31], data_operandB[31]);
  or p30_or(p30, data_operandA[30], data_operandB[30]);
  or p29_or(p29, data_operandA[29], data_operandB[29]);
  or p28_or(p28, data_operandA[28], data_operandB[28]);
  or p27_or(p27, data_operandA[27], data_operandB[27]);
  or p26_or(p26, data_operandA[26], data_operandB[26]);
  or p25_or(p25, data_operandA[25], data_operandB[25]);
  or p24_or(p24, data_operandA[24], data_operandB[24]);

  wire c31, c30, c29, c28, c27, c26, c25;

  // c25 calculations
  wire p24c24;

  and p24c24_and(p24c24, p24, c24);
  or c25_or(c25, g24, p24c24);

  // c26 calculations
  wire p25g24, p25p24c24;

  and p25g24_and(p25g24, p25, g24);
  and p25p24c24_and(p25p24c24, p25, p24, c24);
  or c26_or(c26, g25, p25g24, p25p24c24);

  // c27 calculations
  wire p26g25, p26p25g24, p26p25p24c24;

  and p26g25_and(p26g25, p26, g25);
  and p26p25g24_and(p26p25g24, p26, p25, g24);
  and p26p25p24c24_and(p26p25p24c24, p26, p25, p24, c24);
  or c27_or(c27, g26, p26g25, p26p25g24, p26p25p24c24);

  // c28 calculations
  wire p27g26, p27p26g25, p27p26p25g24, p27p26p25p24c24;

  and p27g26_and(p27g26, p27, g26);
  and p27p26g25_and(p27p26g25, p27, p26, g25);
  and p27p26p25g24_and(p27p26p25g24, p27, p26, p25, g24);
  and p27p26p25p24c24_and(p27p26p25p24c24, p27, p26, p25, p24, c24);
  or c28_or(c28, g27, p27g26, p27p26g25, p27p26p25g24, p27p26p25p24c24);

  // c29 calculations
  wire p28g27, p28p27g26, p28p27p26g25, p28p27p26p25g24, p28p27p26p25p24c24;

  and p28g27_and(p28g27, p28, g27);
  and p28p27g26_and(p28p27g26, p28, p27, g26);
  and p28p27p26g25_and(p28p27p26g25, p28, p27, p26, g25);
  and p28p27p26p25g24_and(p28p27p26p25g24, p28, p27, p26, p25, g24);
  and p28p27p26p25p24c24_and(p28p27p26p25p24c24, p28, p27, p26, p25, p24, c24);
  or c29_or(c29, g28, p28g27, p28p27g26, p28p27p26g25, p28p27p26p25g24, p28p27p26p25p24c24);

  // c30 calculations
  wire p29g28, p29p28g27, p29p28p27g26, p29p28p27p26g25, p29p28p27p26p25g24, p29p28p27p26p25p24c24;

  and p29g28_and(p29g28, p29, g28);
  and p29p28g27_and(p29p28g27, p29, p28, g27);
  and p29p28p27g26_and(p29p28p27g26, p29, p28, p27, g26);
  and p29p28p27p26g25_and(p29p28p27p26g25, p29, p28, p27, p26, g25);
  and p29p28p27p26p25g24_and(p29p28p27p26p25g24, p29, p28, p27, p26, p25, g24);
  and p29p28p27p26p25p24c24_and(p29p28p27p26p25p24c24, p29, p28, p27, p26, p25, p24, c24);
  or c30_or(c30, g29, p29g28, p29p28g27, p29p28p27g26, p29p28p27p26g25, p29p28p27p26p25g24, p29p28p27p26p25p24c24);

  // c31 calculations
  wire p30g29, p30p29g28, p30p29p28g27, p30p29p28p27g26, p30p29p28p27p26g25, p30p29p28p27p26p25g24, p30p29p28p27p26p25p24c24;

  and p30g29_and(p30g29, p30, g29);
  and p30p29g28_and(p30p29g28, p30, p29, g28);
  and p30p29p28g27_and(p30p29p28g27, p30, p29, p28, g27);
  and p30p29p28p27g26_and(p30p29p28p27g26, p30, p29, p28, p27, g26);
  and p30p29p28p27p26g25_and(p30p29p28p27p26g25, p30, p29, p28, p27, p26, g25);
  and p30p29p28p27p26p25g24_and(p30p29p28p27p26p25g24, p30, p29, p28, p27, p26, p25, g24);
  and p30p29p28p27p26p25p24c24_and(p30p29p28p27p26p25p24c24, p30, p29, p28, p27, p26, p25, p24, c24);
  or c31_or(c31, g30, p30g29, p30p29g28, p30p29p28g27, p30p29p28p27g26, p30p29p28p27p26g25, p30p29p28p27p26p25g24, p30p29p28p27p26p25p24c24);

  // G3, P3 calculations
  wire p31g30, p31p30g29, p31p30p29g28, p31p30p29p28g27, p31p30p29p28p27g26, p31p30p29p28p27p26g25, p31p30p29p28p27p26p25g24;

  and p31g30_and(p31g30, p31, g30);
  and p31p30g29_and(p31p30g29, p31, p30, g29);
  and p31p30p29g28_and(p31p30p29g28, p31, p30, p29, g28);
  and p31p30p29p28g27_and(p31p30p29p28g27, p31, p30, p29, p28, g27);
  and p31p30p29p28p27g26_and(p31p30p29p28p27g26, p31, p30, p29, p28, p27, g26);
  and p31p30p29p28p27p26g25_and(p31p30p29p28p27p26g25, p31, p30, p29, p28, p27, p26, g25);
  and p31p30p29p28p27p26p25g24_and(p31p30p29p28p27p26p25g24, p31, p30, p29, p28, p27, p26, p25, g24);

  wire G3, P3;
  or G3_or(G3, g31, p31g30, p31p30g29, p31p30p29g28, p31p30p29p28g27, p31p30p29p28p27g26, p31p30p29p28p27p26g25, p31p30p29p28p27p26p25g24);
  and P3_and(P3, p31, p30, p29, p28, p27, p26, p25, p24);

  // c32 calculation
  wire P3G2, P3P2G1, P3P2P1G0, P3P2P1P0c0;
  and P3G2_and(P3G2, P3, G2);
  and P3P2G1_and(P3P2G1, P3, P2, G1);
  and P3P2P1G0_and(P3P2P1G0, P3, P2, P1, G0);
  and P3P2P1P0c0_and(P3P2P1P0c0, P3, P2, P1, P0, Cin);
  or c32_or(Cout, G3, P3G2, P3P2G1, P3P2P1G0, P3P2P1P0c0);

  // s31-s24 calculations
  xor s24(data_result[24], data_operandA[24], data_operandB[24], c24);
  xor s25(data_result[25], data_operandA[25], data_operandB[25], c25);
  xor s26(data_result[26], data_operandA[26], data_operandB[26], c26);
  xor s27(data_result[27], data_operandA[27], data_operandB[27], c27);
  xor s28(data_result[28], data_operandA[28], data_operandB[28], c28);
  xor s29(data_result[29], data_operandA[29], data_operandB[29], c29);
  xor s30(data_result[30], data_operandA[30], data_operandB[30], c30);
  xor s31(data_result[31], data_operandA[31], data_operandB[31], c31);

endmodule