function [gap_simu, pi_simu, gap_lag_simu_next, ...
            b_pi_simu_next, b_gap_simu_next, ...
            lambda1_simu, gamma_t_simu_next] = ...
            allocations_in_period_i(model, gaintype, states, fspace, parpolicy,...
                benchparameters, b_gap_simu, mcparameters)



%% GIVE INDIVIDUAL NAMES TO PARAMETERS
[alpha, betta, kappa, ~, gam, ~, sigma, ~, ...
    ~, ~, ~, ~, b_x_comm, ...
    b_pi_comm, c_x_comm, c_pi_comm, c_x_discr, ...
    c_pi_discr, ~, ~, ...
    ~,~, ~, ~, ...
    ~, ~, ~, ~, ~, ~, ~, ...
    ~, ~, imp] = translate_parameters(benchparameters);

%% GIVE INDIVIDUAL NAMES TO MC PARAMETERS
[~,~,~,~,~, ~, ~ , ~, shutdownlearning] = translate_mcparameters(mcparameters);

%% POLICY FUNCTION COEFFICIENTS
% Define the coefficients for interpolation of the variables
par0 = reshape(parpolicy,length(parpolicy)/2,2 );
parlambda1 =  par0(:,1);
pargap =      par0(:,2);


%% GIVE INDIVIDUAL NAMES TO STATES
gap_lag_simu = states(:,1);
b_pi_simu = states(:,2);
if strcmp(gaintype,'decr')
    gamma_t_simu = states(:,3);
    costpushshock = states(:,4);
else
    gamma_t_simu = gam; 
    costpushshock = states(:,3);

end

%% GENERATE ALLOCATIONS             
switch model
    case 'MMS'
        gap_simu =funeval(pargap,fspace, states);
        pi_simu = (betta.*b_pi_simu + kappa).*gap_simu +...
            costpushshock;
        gap_lag_simu_next = gap_simu;
        b_pi_simu_next = b_pi_simu  + gap_lag_simu.*(pi_simu - ...
            gap_lag_simu.*b_pi_simu).*gamma_t_simu;
        b_gap_simu_next = b_gap_simu  + gamma_t_simu.*gap_lag_simu.*(gap_simu - gap_lag_simu.*b_gap_simu);

    case 'EHCOMM'        
        gap_simu  = ((1+ (kappa*betta/(alpha + kappa^2)).*b_pi_simu ).^(-1)).*...
            ((alpha/(alpha +  kappa^2)).*gap_lag_simu ...
            -( kappa/(alpha +  kappa^2)).*costpushshock   );
        pi_simu  = (alpha*betta/(alpha + kappa^2)).*b_pi_simu .*gap_simu  + ...
            (alpha*kappa/(alpha +  kappa^2)).*gap_lag_simu  + ...
            ( alpha/(alpha +  kappa^2)).*costpushshock   ;
        gap_lag_simu_next = gap_simu ;
        b_pi_simu_next = b_pi_simu   + gap_lag_simu .*(pi_simu  - ...
            gap_lag_simu .*b_pi_simu ).*gamma_t_simu ;
        b_gap_simu_next = b_gap_simu   + gamma_t_simu .*gap_lag_simu .*(gap_simu  - ...
            gap_lag_simu .*b_gap_simu );
        
    case 'EHDISCR'
        gap_simu = ( -( kappa/(alpha +  kappa^2)).*costpushshock   )./( 1 + (kappa.*betta./(alpha + kappa.^2)).*b_pi_simu ); 
        % gap_simu  = ( -( kappa/(alpha +  kappa^2)).*costpushshock   )./...
        %     (1- b_pi_simu ./sigma -...
        %     b_gap_simu );
        pi_simu = (betta.*b_pi_simu +  kappa).*gap_simu + costpushshock;
        % pi_simu( (betta + kappa./sigma).*b_pi_simu  +...
        %     kappa.*b_gap_simu ).*gap_simu  +  ...
        %     ( alpha/(alpha +  kappa^2)).*costpushshock   ;
        gap_lag_simu_next = gap_simu ;
        b_pi_simu_next = b_pi_simu   + gap_lag_simu .*(pi_simu  - ...
            gap_lag_simu .*b_pi_simu ).*gamma_t_simu ;
        b_gap_simu_next = b_gap_simu   + gamma_t_simu .*gap_lag_simu .*(gap_simu  - ...
            gap_lag_simu .*b_gap_simu );

    case 'RECOMM'
        gap_simu  = b_x_comm.*gap_lag_simu  + ...
            c_x_comm.*costpushshock ;
        pi_simu  = b_pi_comm.*gap_lag_simu  + ...
            c_pi_comm.*costpushshock ;
        gap_lag_simu_next = gap_simu ;
        b_pi_simu_next = b_pi_comm;
        b_gap_simu_next =b_x_comm;
        
        
    case 'REDISCR'
        gap_simu  = c_x_discr.*costpushshock ;
        pi_simu  = c_pi_discr.*costpushshock ;
        gap_lag_simu_next = gap_simu ;
        b_pi_simu_next = 0;
        b_gap_simu_next =0;
        
    case 'NL'
        % compute coefficients
        c_x_NL = - ( (betta.*b_pi_simu + kappa)./ (alpha + (betta.*b_pi_simu + kappa).^2 ) );
        c_pi_NL =   alpha./ (alpha + (betta.*b_pi_simu + kappa).^2 ) ;
        % compute allocations
        gap_simu  = c_x_NL.*costpushshock ;
        pi_simu  = c_pi_NL.*costpushshock ;
        gap_lag_simu_next = gap_simu ;
        b_pi_simu_next = b_pi_simu;
        b_gap_simu_next = b_gap_simu;

    case 'IMP1'
        gap_simu = ( (imp./sigma).*b_pi_simu.*gap_lag_simu - (kappa./ (alpha + kappa.^2)).*costpushshock )./(1 + (kappa.*betta./ (alpha + kappa.^2)).*b_pi_simu);
        pi_simu = (betta.*b_pi_simu + kappa).*gap_simu +...
            costpushshock;
        gap_lag_simu_next = gap_simu;
        b_pi_simu_next = b_pi_simu  + gap_lag_simu.*(pi_simu - ...
            gap_lag_simu.*b_pi_simu).*gamma_t_simu;
        b_gap_simu_next = b_gap_simu  + gamma_t_simu.*gap_lag_simu.*(gap_simu - gap_lag_simu.*b_gap_simu);

    case 'IMP2'
        gap_simu = ( (imp./sigma).*b_gap_simu.*gap_lag_simu - (kappa./ (alpha + kappa.^2)).*costpushshock )./(1 + (kappa.*betta./ (alpha + kappa.^2)).*b_pi_simu);
        pi_simu = (betta.*b_pi_simu + kappa).*gap_simu +...
            costpushshock;
        gap_lag_simu_next = gap_simu;
        b_pi_simu_next = b_pi_simu  + gap_lag_simu.*(pi_simu - ...
            gap_lag_simu.*b_pi_simu).*gamma_t_simu;
        b_gap_simu_next = b_gap_simu  + gamma_t_simu.*gap_lag_simu.*(gap_simu - gap_lag_simu.*b_gap_simu);
end

        if strcmp(gaintype,'decr')
            if shutdownlearning ==1
                gamma_t_simu_next = 0;
            else
                gamma_t_simu_next = gamma_t_simu ./(gamma_t_simu   + 1);
            end
        else
            gamma_t_simu_next =gam;
        end
        
        lambda1_simu  = funeval(parlambda1,fspace, states);
        
end
