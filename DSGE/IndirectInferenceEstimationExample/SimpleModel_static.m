function [residual, g1, g2] = SimpleModel_static(y, x, params)
%
% Status : Computes static model for Dynare
%
% Inputs : 
%   y         [M_.endo_nbr by 1] double    vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1] double     vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1] double   vector of parameter values in declaration order
%
% Outputs:
%   residual  [M_.endo_nbr by 1] double    vector of residuals of the static model equations 
%                                          in order of declaration of the equations
%   g1        [M_.endo_nbr by M_.endo_nbr] double    Jacobian matrix of the static model equations;
%                                                     columns: variables in declaration order
%                                                     rows: equations in order of declaration
%   g2        [M_.endo_nbr by (M_.endo_nbr)^2] double   Hessian matrix of the static model equations;
%                                                       columns: variables in declaration order
%                                                       rows: equations in order of declaration
%
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

residual = zeros( 11, 1);

%
% Model equations
%

T31 = y(4)^(1-params(1));
T40 = exp(y(6))*(1-params(1))*y(3)^params(1)*y(4)^(-params(1));
lhs =y(8);
rhs =y(2)^(-params(4));
residual(1)= lhs-rhs;
lhs =y(9);
rhs =params(10)*exp(y(7));
residual(2)= lhs-rhs;
lhs =y(10);
rhs =params(1)*exp(y(6))*y(3)^(params(1)-1)*T31;
residual(3)= lhs-rhs;
lhs =y(11);
rhs =T40;
residual(4)= lhs-rhs;
lhs =y(8);
rhs =y(8)*params(2)*(1+y(10)-params(3));
residual(5)= lhs-rhs;
lhs =y(9)/y(8);
rhs =y(11);
residual(6)= lhs-rhs;
lhs =y(6);
rhs =y(6)*params(6)+params(7)*x(1);
residual(7)= lhs-rhs;
lhs =y(7);
rhs =y(7)*params(8)+params(9)*x(2);
residual(8)= lhs-rhs;
lhs =y(1);
rhs =T31*exp(y(6))*y(3)^params(1);
residual(9)= lhs-rhs;
lhs =y(5);
rhs =y(1)-y(2);
residual(10)= lhs-rhs;
lhs =y(3);
rhs =y(5)+y(3)*(1-params(3));
residual(11)= lhs-rhs;
if ~isreal(residual)
  residual = real(residual)+imag(residual).^2;
end
if nargout >= 2,
  g1 = zeros(11, 11);

  %
  % Jacobian matrix
  %

  g1(1,2)=(-(getPowerDeriv(y(2),(-params(4)),1)));
  g1(1,8)=1;
  g1(2,7)=(-(params(10)*exp(y(7))));
  g1(2,9)=1;
  g1(3,3)=(-(T31*params(1)*exp(y(6))*getPowerDeriv(y(3),params(1)-1,1)));
  g1(3,4)=(-(params(1)*exp(y(6))*y(3)^(params(1)-1)*getPowerDeriv(y(4),1-params(1),1)));
  g1(3,6)=(-(params(1)*exp(y(6))*y(3)^(params(1)-1)*T31));
  g1(3,10)=1;
  g1(4,3)=(-(y(4)^(-params(1))*exp(y(6))*(1-params(1))*getPowerDeriv(y(3),params(1),1)));
  g1(4,4)=(-(exp(y(6))*(1-params(1))*y(3)^params(1)*getPowerDeriv(y(4),(-params(1)),1)));
  g1(4,6)=(-T40);
  g1(4,11)=1;
  g1(5,8)=1-params(2)*(1+y(10)-params(3));
  g1(5,10)=(-(y(8)*params(2)));
  g1(6,8)=(-y(9))/(y(8)*y(8));
  g1(6,9)=1/y(8);
  g1(6,11)=(-1);
  g1(7,6)=1-params(6);
  g1(8,7)=1-params(8);
  g1(9,1)=1;
  g1(9,3)=(-(T31*exp(y(6))*getPowerDeriv(y(3),params(1),1)));
  g1(9,4)=(-(exp(y(6))*y(3)^params(1)*getPowerDeriv(y(4),1-params(1),1)));
  g1(9,6)=(-(T31*exp(y(6))*y(3)^params(1)));
  g1(10,1)=(-1);
  g1(10,2)=1;
  g1(10,5)=1;
  g1(11,3)=1-(1-params(3));
  g1(11,5)=(-1);
  if ~isreal(g1)
    g1 = real(g1)+2*imag(g1);
  end
end
if nargout >= 3,
  %
  % Hessian matrix
  %

  g2 = sparse([],[],[],11,121);
end
end
