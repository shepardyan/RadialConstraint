% Take 33 node distribution system as an example
mpc = case33bw;

% constraint definition
[constraints, c_var, flow_aux_var] = radial_constraints(mpc, []);

% objective definition
obj = -sum(c_var);

% optimization procedure
optimize(constraints, obj);

% Visualize result
disp(value(c_var))