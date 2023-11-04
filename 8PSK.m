clc;clear;close all
N = 1e4-1;
M = 8;
P0 = round(N/2);
P1 = N - P0;
input_bits = zeros(1, N); % All zeros to start.
indexes = randperm(N, P1);
input_bits(indexes) = 1;
sum(input_bits) % check the number of ones
P0 = P0/N; % check
P1 = P1/N; % check
R = 1; % rate


% Bit mapping
m_bits_2 = [];
for ij = 1:3:N
    if input_bits(ij) == 0 && input_bits(ij+1) == 0 && input_bits(ij+2) == 0
        map_bits = cosd(0) + 1*1j*sind(0) ;
    elseif input_bits(ij) ==0 && input_bits(ij+1) == 0 && input_bits(ij+2) == 1
        map_bits = cosd(45) + 1*1j*sind(45) ;
    elseif input_bits(ij) ==0 && input_bits(ij+1) == 1 && input_bits(ij+2) == 1
        map_bits = cosd(90) + 1*1j*sind(90) ;
    elseif input_bits(ij) ==0 && input_bits(ij+1) == 1 && input_bits(ij+2) == 0
        map_bits = cosd(135) + 1*1j*sind(135) ;
    elseif input_bits(ij) ==1 && input_bits(ij+1) == 1 && input_bits(ij+2) == 0
        map_bits = cosd(180) + 1*1j*sind(180) ;
    elseif input_bits(ij) ==1 && input_bits(ij+1) == 1 && input_bits(ij+2) == 1
        map_bits = cosd(225) + 1*1j*sind(225) ;
    elseif input_bits(ij) ==1 && input_bits(ij+1) == 0 && input_bits(ij+2) == 1
        map_bits = cosd(270) + 1*1j*sind(275) ;
    elseif input_bits(ij) ==1 && input_bits(ij+1) == 0 && input_bits(ij+2) == 0
        map_bits = cosd(315) + 1*1j*sind(315) ;
  
    end
    m_bits_2 = [m_bits_2 map_bits];
end

%sctter(map_bits_2)
scatterplot(m_bits_2)


ber_sim = zeros(1,19);
ber_theory_erfc = zeros(1,19);
x = 1;

for SNR = 3:0.5:12 %SNR value in dB
    EbN0 = 10^(SNR/10); %convert to normal scale
    n = (1/sqrt(2))*[randn(1,length(m_bits_2))+ 1j*randn(1,length(m_bits_2))];
    sigma = sqrt(1/(log2(M)*EbN0));
   
    rcv_bits = m_bits_2 +sigma.*n; %AWGN channel with random numbers

    trans = [cosd(0)+1j*sind(0), cosd(45)+1j*sind(45), cosd(90)+1j*sind(90),...
            cosd(135)+1j*sind(135), cosd(180)+1j*sind(180), cosd(225)+1j*sind(225),...
            cosd(270)+1j*sind(270), cosd(315)+1j*sind(315)];
    
    det_bits = [];
    err = [];
    map_bits_2 = [];
    for mm = 1:length(rcv_bits)
        for zz = 1:length(trans)
            a = (real (rcv_bits(mm)) - real(trans(zz)))^2;
            b = (imag (rcv_bits(mm)) - imag(trans(zz)))^2;
            err(zz) = sqrt(a+b);
        end
        identify = trans(find(err==min(err)));
    map_bits_2 = [map_bits_2 identify];
    end
    
    receive_bits = [];
    for m = 1:length(map_bits_2)
        if real(map_bits_2(m)) == cosd(0) && imag(map_bits_2(m)) == sind(0) 
            rcv_bits_2 = [0 0 0];
        elseif real(map_bits_2(m)) == cosd(45) && imag(map_bits_2(m)) == sind(45) 
            rcv_bits_2 = [0 0 1];
        elseif real(map_bits_2(m)) == cosd(90) && imag(map_bits_2(m)) == sind(90) 
            rcv_bits_2 = [0 1 1];
        elseif real(map_bits_2(m)) == cosd(135) && imag(map_bits_2(m)) == sind(135)  
            rcv_bits_2 = [0 1 0];
        elseif real(map_bits_2(m)) == cosd(180) && imag(map_bits_2(m)) == sind(180) 
            rcv_bits_2 = [1 1 0];
        elseif real(map_bits_2(m)) == cosd(225) && imag(map_bits_2(m)) == sind(225) 
            rcv_bits_2 = [1 1 1];
        elseif real(map_bits_2(m)) == cosd(270) && imag(map_bits_2(m)) == sind(270) 
            rcv_bits_2 = [1 0 1];
        elseif real(map_bits_2(m)) == cosd(315) && imag(map_bits_2(m)) == sind(315) 
            rcv_bits_2 = [1 0 0];
        end
    receive_bits = [receive_bits rcv_bits_2];
    end
    noe = sum(input_bits~=receive_bits); %number of errors
    ber_sim1 = noe/N; %bit error rate calculation with simulation values
    ber_sim(1,x) = ber_sim1;
    ber_th_er = (1/3)*erfc(sqrt(3*EbN0)*sind(180/8)); %theoretical bit error rate calculation
    ber_theory_erfc(1,x) = ber_th_er;
    x = x+1;

end

scatterplot(rcv_bits)

figure(3);
clf
SNR = 3:0.5:12;
semilogy(SNR,ber_sim,'->',SNR,ber_theory_erfc,'-d','lineWidth',2);
legend('BER of 8PSK for P = 0.5','Theoritical BER for 8PSK','Location','Best')
xlabel('Eb/N0 (dB)', 'FontSize', 11);
ylabel('BER', 'FontSize', 11);
grid on
hold on
ylim([1e-4 1])


