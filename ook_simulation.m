clc;clear; close all;

%random input bits
N=100000;

R = (randi([0 1],1,N)); %Data bits
m = 0 + ((1-0).* R ); %Data bits values

%OOK Mapping
x=zeros(1, N);

for i=1:N
    if m(i) == 0
        x(i) = 0;
    else
        x(i) = 1;
    end
end

ber_sim = zeros(1,16); %Preallocating for speed--bit error rate
ber_sim_2 = zeros(1,16);
ber_theory_erfc = zeros(1,16);

for EbN0dB = 0:1:15 %SNR value in dB
    EbN0 = 10^(EbN0dB/10); %convert to normal scale
    sigma = sqrt(1/(2*EbN0));
    r = m+sigma.*randn(1,N); %AWGN channel with random numbers

    r2 =  awgn (m, EbN0dB, 'measured');
    m_cap=(r>0.5); %detected bits, thresold=0.5
    m_cap_2=(r2>0.5);

    %BER calculation
    noe = sum(x~=m_cap); %number of errors, sum if m is not equal to m_cap
    noe_2 = sum(x~=m_cap_2);
    ber_sim(1,EbN0dB+1) = noe/N; %bit error rate calculation with simulation values
    ber_sim_2(1,EbN0dB+1) = noe_2/N;
    ber_theory_erfc(1,EbN0dB+1) = 0.5*erfc(sqrt(EbN0/4)); %theoretical bit error rate calculation

end


EbN0dB=0:1:15;
semilogy(EbN0dB,ber_sim,'*-',EbN0dB,ber_theory_erfc,'o-',EbN0dB,ber_sim_2,'d-','linewidth',1.5);
xlabel('Eb/N0(dB)');
ylabel('BER');
legend('Simulation sigma','Theory(erfc)', 'Simulation awgn');
grid on;