%This script load DCS g1 curves generated by Monte Carlo and fit them with a
%two-layered model

%Louis Gagnon 9-13-2010
%lgagnon@nmr.mgh.harvard.edu


%global variable and parameters

global k0
global rho
global mu_a1
global mu_a2
global mu_s1
global mu_s2
global D1
global D2
global z0
global zb
global L
global tau
global S
global coeff


lambda=690; %in nm
lambda=lambda*1e-6; %conversion in mm
k0=2*pi/lambda;
c=0.214; % in mm/ps
g = 0; % anisotropy factor
rho=15; % in mm
mu_a1=0.00704; % mm^-1
mu_s1=1.28*(1-g); % mm^-1
mu_a2=0.00704;
mu_s2=1.28*(1-g);
D1=(3*(mu_a1+mu_s1))^(-1);
D2=(3*(mu_a2+mu_s2))^(-1);
z0=(mu_a1+mu_s1).^(-1);
zb=5.889546*D1;
L=10; %thickness of the first layer in mm


%Stuff for the Gauss-Laguerre quadrature
load gauss_lag_5000.mat
cutoff=300;%at higher value the fct is zero
S=gl(1:cutoff,2);
coeff=gl(1:cutoff,3);

%load the MC data
load g1.mat
idx=4; %can go 1 to 4


%begin the fitting procedure
%           [ Db_1       Db_2     ]
Starting =  [ 1e-8       1e-6     ]; 
lower_bound=[ 1e-9       1e-9     ];
upper_bound=[ 1e-5       1e-5     ];
options=optimset('Display','final','MaxFunEvals',1000,'MaxIter', 1000,'TolX',1e-6,'TolFun',1e-6);
Estimates =lsqcurvefit(@g1twolayers,Starting,tau,g1(:,idx),lower_bound,upper_bound,options); 

Db_1=Estimates(1);
Db_2=Estimates(2);


Phi=zeros(size(tau,1),1);
for i=1:size(tau,1);
A1=((D1*S.^2+mu_a1+1/3*mu_s1*k0.^2*6*Db_1.*tau(i))/D1).^(1/2);
A2=((D2*S.^2+mu_a2+1/3*mu_s2*k0.^2*6*Db_2.*tau(i))/D2).^(1/2);
DA=(D1.*A1-D2.*A2)./(D1.*A1+D2.*A2);

PHIK=((exp(A1*z0)-exp(-A1*(2.*zb+z0))).*(1+DA.*exp(-2.*A1*L))./(1+DA.*exp(-2.*A1*(L+zb)))-(exp(A1*z0)-exp(-A1*z0)))./(2.*D1.*A1);

fct=exp(S).*PHIK.*S.*besselj(0,rho.*S);
Phi(i)=1/(2*pi)*sum(coeff.*fct,1);
end
Phi=Phi./max(Phi);


%plot the fitted curve
fig1=figure;
semilogx(tau,g1(:,idx),'.b')
hold on
semilogx(tau,Phi,'r','LineWidth',1)
text(0.001,1.0,['D_{B1} = ',sprintf('%0.3g',Db_1),' mm^{2}/s'],'FontSize',16)
text(0.001,0.9,['D_{B2} = ',sprintf('%0.3g',Db_2),' mm^{2}/s'],'FontSize',16)
title('Two-layered fit','FontSize',15);
xlabel('\tau (s)','FontSize',15);
ylabel('g1(\tau)','FontSize',15);
ylim([0 1.1]);











