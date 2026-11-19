function modal_animation
    num_masses = 4;
    total_mass = 4;
    tension_force = 10;
    string_length = 10;
    damping_coeff = 0.3;

    dx = string_length/(num_masses+1);

    amplitude_Uf = 2;
    omega_Uf = 2;

    %list of x points (including the two endpoints)
    xlist = linspace(0,string_length,num_masses+2);
    
    Uf_func = @(t_in) amplitude_Uf*cos(omega_Uf*t_in);
    dUfdt_func = @(t_in) -omega_Uf*amplitude_Uf*sin(omega_Uf*t_in);

    %generate the struct
    string_params = struct();
    string_params.n = num_masses;
    string_params.M = total_mass;
    string_params.Uf_func = Uf_func;
    string_params.dUfdt_func = dUfdt_func;
    string_params.Tf = tension_force;
    string_params.L = string_length;
    string_params.c = damping_coeff;
    string_params.dx = dx;

    [M_mat,K_mat] = construct_2nd_order_matrices(string_params)
    %Use MATLAB to solve the generalized eigenvalue problem
    [Ur_mat,lambda_mat] = eig(K_mat,M_mat);

    %...
end 