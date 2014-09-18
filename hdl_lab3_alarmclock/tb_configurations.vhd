configuration cfg_counter_sig2 of test is
  for tb_counter_sig
    for U1: counter_sig use entity
            work.counter_sig(Arch_counter_sig2);
    end for;
  end for;
end cfg_counter_sig2;
configuration cfg_counter_var of test is
  for tb_counter_sig
    for U1: counter_sig use entity
            work.counter_sig(Arch_counter_var);
    end for;
  end for;
end cfg_counter_var;
