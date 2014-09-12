ENTITY mux IS
PORT(
D0: IN BIT; -- Input data signal A.
D1: IN BIT; -- Input data signal B.
S: IN BIT; -- Control signal.
Z: OUT BIT -- Output data signal.
);
END mux;
ARCHITECTURE rtl OF mux IS
COMPONENT nandgate
PORT(
A: IN BIT;
B: IN BIT;
Q: OUT BIT
);
END COMPONENT;
SIGNAL S_inv, Z_prim_1, Z_prim_2: BIT;
BEGIN
N1: nandgate PORT MAP (D0, S, Z_prim_2);
N2: nandgate PORT MAP (S, S, S_inv);
N3: nandgate PORT MAP (S_inv, D1, Z_prim_1);
N4: nandgate PORT MAP (Z_prim_2, Z_prim_1, Z);
END rtl;
