function [h,g,rh,rg]=maxflat(N0,Npi)

%MAXFLAT    Generates maximally flat FIR filters.
%
%           [H,G,RH,RG] = MAXFLAT(N0,NPI) where (N0-1) is the degree
%	    of flatness at w=0 and (NPI-1) at w=pi radians. 
%	    This function returns half band filters only if N0=NPI.
%	    Otherwise, they cannot be passed to WT, WPK.
%
%           H is the analysis lowpass filter, RH the synthesis 
%           lowpass filter, G the analysis highpass filter and
%           RG the synthesis highpass filter.
%
%	    For a given order, an increase in NPI results in a wider
%           stopband. 
%
% 	    References: P.P. Vaidyanathan, "Multirate Systems and
%	                Filter Banks", Prentice-hall, pp. 532-535.


%--------------------------------------------------------
% Copyright (C) 1994, 1995, 1996, by Universidad de Vigo 
%                                                      
%                                                      
% Uvi_Wave is free software; you can redistribute it and/or modify it      
% under the terms of the GNU General Public License as published by the    
% Free Software Foundation; either version 2, or (at your option) any      
% later version.                                                           
%                                                                          
% Uvi_Wave is distributed in the hope that it will be useful, but WITHOUT  
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or    
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License    
% for more details.                                                        
%                                                                          
% You should have received a copy of the GNU General Public License        
% along with Uvi_Wave; see the file COPYING.  If not, write to the Free    
% Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.             
%                                                                          
%       Author: Nuria Gonzalez Prelcic
%       e-mail: Uvi_Wave@tsc.uvigo.es
%--------------------------------------------------------


poly=[];		% Calculate trigonometric polynomial
for i=1:N0
	poly=[poly , 2*numcomb(Npi+i-2,i-1)];
end
poly=poly(length(poly):-1:1);
zerospoly=roots(poly);	% Calculate roots

% Transform roots

rootsz=[];

for i=1:length(zerospoly)
    rooty=zerospoly(i);
    rootz1=(1-2*rooty)-2*sqrt(rooty*(rooty-1));
    rootz2=(1-2*rooty)+2*sqrt(rooty*(rooty-1));
    rootsz=[rootsz,rootz1,rootz2];
end     

zeros=rootsz;
N=length(zeros);

% To construct rh for the minimum phase choice, we choose all the zeros 
% inside the unit circle. 

modulus=abs(zeros);

j=1;
for i=1:N
	if modulus(i)<1
		zerosinside(j)=zeros(i);
		j=j+1;
	end
end

An=poly(1);

realzeros=[];
imagzeros=[];
numrealzeros=0;
numimagzeros=0;


Ni=length(zerosinside);

for i=1:(Ni)
	if (imag(zerosinside(i))==0)
		numrealzeros=numrealzeros+1;
		realzeros(numrealzeros)=zerosinside(i);
	else
		numimagzeros=numimagzeros+1;
		imagzeros(numimagzeros)=zerosinside(i);	
		
	end
end

% Construction of rh from its zeros

rh=[1 1];

for i=2:N0
	rh=conv(rh,[1 1]);
end

for i=1:numrealzeros
	rh=conv(rh,[1 -realzeros(i)]);
end

for i=1:2:numimagzeros
	rh=conv(rh,[1 -2*real(imagzeros(i)) abs(imagzeros(i))^2]);
end

% Normalization

rh=sqrt(2)/sum(rh)*rh;

% Calculate h,g,rg

[rh,rg,h,g]=rh2rg(rh);
