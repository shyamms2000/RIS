function [Y_proposed_hbf, W_e, Psi_bar, Omega, Y] = proposed_hbf(H, N, Psi_i, T, Lr_e, Lr, W)

   %% Parameter initialization
   [~, Nt, L] = size(H);

   
   %% Variables initialization
   Psi_bar = zeros(Nt, T, L);

   %% Wideband channel modeling
   W_e = W(:, 1:Lr_e);
   
   % Construct the received signal
   Y = zeros(size(N));
   for l=1:L
    for k=1:Nt
     Psi_bar(k,:,l) = Psi_i(l,:,k);
    end
    Y = Y + H(:,:,l)*Psi_bar(:,:,l);
   end
   
   R = Y + N;

   %% Proposed HBF architecture
   Omega = eye(Lr_e, T);
   indices = randperm(T);
   Omega = Omega(:, indices);
   for i=2:Lr
    indices = randperm(T);
    Omega = Omega + Omega(:, indices);
   end
   Y_proposed_hbf = Omega.*(W_e'*R);
   
end
