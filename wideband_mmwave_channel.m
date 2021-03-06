function [H,Zbar,Ar,At,Dr,Dt] = wideband_mmwave_channel(L, Mr, Mt, total_num_of_clusters, total_num_of_rays, Gr, Gt, type)

% Initialization
H = zeros(Mr, Mt, L);
Z = zeros(Gr, Gt, L);
Ar = zeros(Mr, total_num_of_clusters*total_num_of_rays, L);
At = zeros(Mt, total_num_of_clusters*total_num_of_rays, L);
Dr = 1/sqrt(Mr)*exp(-1j*(0:Mr-1)'*2*pi*(0:Gr-1)/Gr);
Dt = 1/sqrt(Mt)*exp(-1j*(0:Mt-1)'*2*pi*(0:Gt-1)/Gt);

  for l=1:L

   Hl = zeros(Mr, Mt);
   index = 1;
   for tap = 1:total_num_of_clusters
       for ray=1:total_num_of_rays
           rayleigh_coeff = 1/sqrt(2)*(randn(1)+1j*randn(1));
           switch(type)
               case 'ULA'
                    phi_r = genLaplacianSamples(1);
                    Ar(:, index, l) = mmwave_angle(phi_r, Mr);
                    phi_t = genLaplacianSamples(1);
                    At(:, index, l) = mmwave_angle(phi_t, Mt);
               case 'UPA'
                    phi_r = genLaplacianSamples(1);
                    theta_r = genLaplacianSamples(1);
                    Ar(:, index, l) = mmwave_angle(phi_r, Mr).* mmwave_angle(theta_r, Mr);
                    phi_t = genLaplacianSamples(1);
                    theta_t = genLaplacianSamples(1);
                    At(:, index, l) = mmwave_angle(phi_t, Mt).* mmwave_angle(theta_t, Mt);
                   
           end

           Hl = Hl + rayleigh_coeff*Ar(:, index)*At(:, index)';

           index = index + 1;
       end
       H(:,:,l) = H(:,:,l) + Hl;
   end

   H(:,:,l) = sqrt(Mr*Mt)/sqrt(total_num_of_rays*total_num_of_clusters)*H(:,:,l);
   Z(:,:,l) = Dr'*H(:,:,l)*Dt;
    end
  
  Zbar = reshape(Z, Gr, L*Gt);
end

% Generate the transmit and receive array responces
function vectors_of_angles=mmwave_angle(phi, M)

    % For Uniform Linear Arrays (ULA) compute the phase shift
    Ghz = 30;
    wavelength = 30/Ghz; % w=c/lambda
    array_element_spacing = 0.5*wavelength;
    wavenumber = 2*pi/wavelength; % k = 2pi/lambda
    phi0 = 0; % mean AOA
    phase_shift = wavenumber*array_element_spacing*sin(phi0-phi)*(0:M-1).';
    vectors_of_angles = 1/sqrt(M)*exp(-1j*phase_shift);
end


% Random variable generator based on inverse transform sampling
function x=genLaplacianSamples(N)
    u = rand(N,1);
    % Inverse transform of trancuted Laplacian
    sigma_phi = 50; % standard deviation of the power azimuth spectrum (PAS)
    beta = 1/(1-exp(-sqrt(2)*pi/sigma_phi));
    x = beta*(exp(-sqrt(2)/sigma_phi*pi) - cosh(u));
end