function [constraints, c, flow] = radial_constraints(mpc, constraints)
% define constants for MATPOWER modeling
define_constants;

% define constants of specific MATPOWER CASE
[ref, ~, ~] = bustypes(mpc.bus, mpc.gen);
nb = size(mpc.bus, 1);
nl = size(mpc.branch, 1);
ngen = size(mpc.gen, 1);
nref = length(ref);

% initialize variables
c = binvar(nl, 1);
flow = sdpvar(nl, 1);

% start constraints modeling
for i = 1:nl
    % Equation (3a) is eliminated using the compactness form f_{ij}^{-} = c_{ij} - f_{ij}^{+}
    constraints = [constraints, flow(i) >= ...                     % Equation (5)
        (1/(nb - nref + 1)) * c(i)];
    constraints = [constraints, c(i) - flow(i) >= ...              % Equation (5)
        (1/(nb - nref + 1)) * c(i)];
end

source_cons = [];
for i = 1:nb
    iIndexFrom = find(mpc.branch(:, F_BUS) == i);
    iIndexTo   = find(mpc.branch(:, T_BUS) == i);
    if i ~= ref
        constraints = [constraints, sum(flow(iIndexTo)) + ...       % Equation (3b)
            sum(c(iIndexFrom) - flow(iIndexFrom)) <= (nb - nref) / (nb - nref + 1)];
    else
        source_cons = [source_cons, sum(flow(iIndexTo)) + ...       % Equation (3c)
            sum(c(iIndexFrom) - flow(iIndexFrom))];
    end
end
constraints = [constraints, sum(source_cons) <= ...                 % Equation (3c)
    (nb - nref) / (nb - nref + 1)];
constraints = [constraints, flow >= 0];                             % Equation (3d)

end