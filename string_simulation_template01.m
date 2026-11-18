function string_simulation_template01()
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
    %load string_params into rate function
    my_rate_func = @(t_in,V_in) string_rate_func01(t_in,V_in,string_params);
    %initial conditions
    U0 = zeros(num_masses,1);
    dUdt0 = zeros(num_masses,1);
    V0 = [U0;dUdt0];
    tspan = [0 30];
    %run the integration
    Fehlberg = struct();
    Fehlberg.C = [0, 1/4, 3/8, 12/13, 1, 1/2];
    Fehlberg.B = [16/135, 0, 6656/12825, 28561/56430, -9/50, 2/55;...
    25/216, 0, 1408/2565, 2197/4104, -1/5, 0];
    Fehlberg.A = [0,0,0,0,0,0;...
    1/4, 0,0,0,0,0;...
    3/32, 9/32, 0,0,0,0;...
    1932/2197, -7200/2197, 7296/2197, 0,0,0;...
    439/216, -8, 3680/513, -845/4104, 0,0;...
    -8/27, 2, -3544/2565, 1859/4104, -11/40, 0];
    
    p = 5;                 
    error_desired = 1e-5;
    h_ref = 0.05;
    

    string_plot = plot(0, 0, 'k', 'linewidth', 2);
    [tlist,Vlist] = explicit_RK_variable_step_integration(my_rate_func,tspan,V0,h_ref,Fehlberg,p,error_desired);
    

    mypath1 = 'C:\Users\sbechu\OneDrive - Olin College of Engineering\Documents\GitHub\mth3199_assignment6\';
    fname='string_video.mp4';
    input_fname = [mypath1,fname];

    %create a videowriter, which will write frames to the animation file
    writerObj = VideoWriter(input_fname);

    %must call open before writing any frames
    open(writerObj);

    %initialize the current figure and save as object
    fig1 = figure(1);
    xlabel('x-axis (-)', 'Interpreter', 'latex','FontSize',15);
    ylabel('y-axis (-)', 'Interpreter','latex','FontSize',15)
    title('Vibrating String Simulation Animation', 'Interpreter', 'latex','FontSize',20)

    set(fig1,'units','pixels','position',[100 100 1440 1440]);
    set(fig1,'resize','off');
    
    hold on;
    axis equal;
    axis([-5, 15, -15, 15])

    xplotlist = xlist;
    masses = plot(xlist(2:end-1), zeros(1,num_masses), 'ko', 'MarkerSize', 10);

    for i = 1:length(tlist)
        % plot the string
        yplotlist = [0, Vlist(i,1:num_masses), Uf_func(tlist(i))];
        set(string_plot,'xdata',xplotlist,'ydata',yplotlist, 'Marker', '.', 'Markersize', 50)

        set(masses,'xdata',xlist(2:end-1),'ydata',Vlist(i,1:num_masses));

        % % plot the masses
        % for j = 2:length(xlist)-1
        %     xlist(j)
        %     Vlist(i,j)
        %     set(string_plot,'xdata',xlist(j),'ydata',Vlist(i,j))
        % end
        
        %write the frame to the video
        pause(0.01);
        axis equal; 
        axis square
        axis([-5, 15, -15, 15])

        hold on;
        drawnow;

        %capture a frame (what is currently plotted)
        current_frame = getframe(gcf);
        writeVideo(writerObj,current_frame)
        drawnow;
    end
    close(writerObj)
 
end